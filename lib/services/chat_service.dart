import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nurox_chat/models/message.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/screens/view_image.dart';
import 'package:nurox_chat/utils/firebase.dart';

class ChatService {
  FirebaseStorage storage = FirebaseStorage.instance;

  sendMessage(Message message, String chatId) async {
    //will send message to chats collection with the usersId
    await chatRef.doc("$chatId").collection("messages").add(message.toJson());
    //will update "lastTextTime" to the last time a text was sent
    await chatRef.doc("$chatId").update({"lastTextTime": Timestamp.now()});
  }

  Future<String> sendFirstMessage(Message message, String recipient) async {
    User user = firebaseAuth.currentUser!;
    DocumentReference ref = await chatRef.add({
      'users': [recipient, user.uid],
    });
    await sendMessage(message, ref.id);
    return ref.id;
  }

  Future<String> uploadImage(File image, String chatId) async {
    Reference storageReference =
        storage.ref().child("chats").child(chatId).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }

//determine if a user has read a chat and updates how many messages are unread
  setUserRead(String chatId, UserModel user, int count) async {
    DocumentSnapshot snap = await chatRef.doc(chatId).get();
    Map reads = snap.get('reads') ?? {};
    reads[user.id] = count;
    await chatRef.doc(chatId).update({'reads': reads});
  }

  //determine when a user has start typing a message
  setUserTyping(String chatId, UserModel user, bool userTyping) async {
    DocumentSnapshot snap = await chatRef.doc(chatId).get();
    Map typing = snap.get('typing') ?? {};
    typing[user.id] = userTyping;
    await chatRef.doc(chatId).update({
      'typing': typing,
    });
  }

// You will need to pass the current user ID to this function.
// This function must return a Stream<int>.
  Stream<int> getNumberOfUnreadMessages(String currentUserId) {
    // 1. Stream the main chat documents where the user is a participant.
    return chatRef
        .where('users', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((querySnapshot) async {
      int totalUnread = 0;

      // 2. Iterate through each chat document.
      for (var chatDoc in querySnapshot.docs) {
        final chatId = chatDoc.id;

        // Safely read the 'reads' map from the chat document.

        final reads = chatDoc['reads'] as Map<String, dynamic>? ?? {};

        // Get the current user's last read message count.
        final int readCount = (reads[currentUserId] as int?) ?? 0;

        final messagesQuery = await chatRef
            .doc(chatId)
            .collection('messages')
            .count() // <-- Use the count() method for the actual number of documents
            .get();

        // Extract the count.
        final int totalMessagesInChat = messagesQuery.count ?? 0;

        // 4. Calculate unread count for the current chat.
        final int unreadCountForChat = totalMessagesInChat > readCount
            ? totalMessagesInChat - readCount
            : 0;

        // 5. Accumulate the total unread count.
        totalUnread += unreadCountForChat;
      }

      // 6. Return the aggregated result.
      return totalUnread;
    });
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return chatRef
        .doc(documentId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> userChatsStream(String uid) {
    return chatRef
        .where('users', arrayContains: '$uid')
        .orderBy('lastTextTime', descending: true)
        .snapshots();
  }
}
