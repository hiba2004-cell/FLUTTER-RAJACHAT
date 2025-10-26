import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:nurox_chat/components/chat_bubble.dart';
import 'package:nurox_chat/models/enum/message_type.dart';
import 'package:nurox_chat/models/message.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/pages/profile.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:nurox_chat/view_models/conversation/conversation_view_model.dart';
import 'package:nurox_chat/view_models/user/user_view_model.dart';
import 'package:nurox_chat/widgets/indicators.dart';
import 'package:timeago/timeago.dart' as timeago;

class Conversation extends StatefulWidget {
  final String userId;
  final String chatId;

  const Conversation({super.key, required this.userId, required this.chatId});

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  bool isFirst = false;
  // Local state to hold the resolved chatId once it's created or verified
  String? chatId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      viewModel.setUser();
    });

    scrollController.addListener(() {
      // Unfocusing the keyboard also triggers setTyping(false) via focusNode listener
      focusNode.unfocus();
    });

    if (widget.chatId == 'newChat') {
      isFirst = true;
      chatId =
          null; // Initial chatId is null until the first message is sent and chat is created
    } else {
      chatId = widget.chatId;
    }

    // Listener for focus changes to handle typing status when focus changes
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // Only set typing true if text is actually present
        setTyping(messageController.text.isNotEmpty);
      } else {
        setTyping(false);
      }
    });

    // Listener for text changes to update typing status in real-time
    messageController.addListener(() {
      setTyping(messageController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    // Crucial: Set typing to false when the conversation screen is disposed
    setTyping(false);
    focusNode.dispose();
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  setTyping(bool typing) {
    // Only proceed if mounted AND chatId is resolved (i.e., not null)
    if (!mounted || chatId == null) return;

    // Use context.read for non-listening access
    final user = context.read<UserViewModel>().user;
    final convViewModel = context.read<ConversationViewModel>();

    if (user != null) {
      // Use the resolved chatId instead of widget.chatId
      convViewModel.setUserTyping(chatId!, user, typing);
    }
  }

  sendMessage(ConversationViewModel viewModel, UserModel? user,
      {bool isImage = false, int? imageType}) async {
    if (user == null) {
      print('Sender user is null, cannot send message.');
      return;
    }

    String? msgContent;

    if (isImage) {
      // Assuming pickImage returns the download URL or null on failure
      msgContent = await viewModel.pickImage(
        source: imageType!,
        context: context,
        chatId: widget.chatId,
      );
    } else {
      msgContent = messageController.text.trim();
      messageController.clear();
      // Ensure typing status is turned off immediately after sending text
      setTyping(false);
      focusNode.unfocus();
    }

    // Only proceed if there is content to send
    if (msgContent == null || msgContent.isEmpty) return;

    // Build the Message object
    Message message = Message(
      content: msgContent,
      senderUid: user.id,
      type: isImage ? MessageType.IMAGE : MessageType.TEXT,
      time: Timestamp.now(),
    );

    if (isFirst) {
      // --- Handle First Message ---
      print("Sending FIRST message...");

      // Send the first message and get the new chatId
      String newChatId =
          await viewModel.sendFirstMessage(widget.userId, message);

      setState(() {
        isFirst = false;
        chatId = newChatId; // Update local chatId
      });

      // Initialize the chat document fields (typing/reads/users)
      chatRef.doc(newChatId).set({
        "users": [firebaseAuth.currentUser!.uid, widget.userId],
        "lastTextTime": Timestamp.now(),
        "reads": {},
        "typing": {},
      }, SetOptions(merge: true));
    } else if (chatId != null) {
      // --- Handle Subsequent Messages ---
      viewModel.sendMessage(chatId!, message);
    }

    // Scroll to the bottom after sending a message
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the current user once using context.watch for necessary rebuilds,
    final userViewModel = Provider.of<UserViewModel>(context);
    userViewModel.setUser();
    final UserModel? currentUser = userViewModel.user;

    // Handle the case where the current user is not yet loaded
    if (currentUser == null) {
      return Scaffold(body: Center(child: circularProgress(context)));
    }

    return Consumer<ConversationViewModel>(
      builder: (BuildContext context, viewModel, Widget? child) {
        return Scaffold(
          key: viewModel.scaffoldKey,
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.keyboard_backspace),
            ),
            elevation: 0.0,
            titleSpacing: 0,
            title: buildUserName(currentUser),
          ),
          body: Column(
            children: [
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  // Use the resolved chatId for the stream
                  stream: (chatId != null) ? messageListStream(chatId!) : null,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Say Hello!"));
                    }

                    final messages = snapshot.data!.docs;

                    // Call setReadCount on every data update
                    viewModel.setReadCount(
                        widget.chatId, currentUser, messages.length);

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      itemCount: messages.length,
                      reverse: true, // Show newest messages at the bottom
                      itemBuilder: (BuildContext context, int index) {
                        final messageDoc = messages[index];

                        final messageData =
                            messageDoc.data() as Map<String, dynamic>?;

                        if (messageData == null) return const SizedBox.shrink();

                        Message message = Message.fromJson(messageData);

                        return ChatBubbleWidget(
                          message: message.content ?? '',
                          time: message.time!,
                          isMe: message.senderUid == currentUser.id,
                          type: message.type ?? MessageType.TEXT,
                        );
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomAppBar(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 10.0,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 100.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.photo_on_rectangle,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () =>
                              showPhotoOptions(viewModel, currentUser),
                        ),
                        Flexible(
                          child: TextField(
                            controller: messageController,
                            focusNode: focusNode,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontSize: 15.0,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .color,
                                ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10.0),
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none,
                              hintText: "Type your message",
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                              ),
                            ),
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Ionicons.send,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () {
                            if (messageController.text.trim().isNotEmpty) {
                              // FIX 10: Ensure you pass the current user model
                              sendMessage(viewModel, currentUser);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // FIX 11: Corrected StreamBuilder to use nested streams for Online Status (from User Doc) and Typing Status (from Chat Doc)
  Widget buildUserName(UserModel currentUser) {
    // Stream 1: Recipient's User Document (for online status)
    return StreamBuilder<DocumentSnapshot>(
      stream: usersRef.doc(widget.userId).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("Loading..."));
        }

        final recipientUser = UserModel.fromJson(
          userSnapshot.data!.data() as Map<String, dynamic>,
        );

        // Stream 2: Chat Document (for typing status)
        // We need the resolved chatId here, which may be null for a new chat.
        return StreamBuilder<DocumentSnapshot>(
          stream: (chatId != null) ? chatRef.doc(chatId!).snapshots() : null,
          builder: (context, chatSnapshot) {
            // Default to not typing if chat document isn't available or loading
            bool isTyping = false;

            if (chatSnapshot.hasData && chatSnapshot.data!.exists) {
              final chatData =
                  chatSnapshot.data!.data() as Map<String, dynamic>?;
              final typingData =
                  chatData?['typing'] as Map<String, dynamic>? ?? {};

              // Check if the recipient (widget.userId) is typing in THIS chat
              isTyping = typingData[widget.userId] == true;
            }

            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => Profile(profileId: recipientUser.id!),
                  ),
                );
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Hero(
                      tag: recipientUser.email ?? 'default_tag',
                      child: recipientUser.photoUrl!.isEmpty
                          ? CircleAvatar(
                              radius: 20.0, // Reduced size for app bar
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              child: Center(
                                child: Text(
                                  recipientUser.username![0].toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage(recipientUser.photoUrl!),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          recipientUser.username ?? 'User',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          // Use the combined logic here
                          _buildOnlineText(recipientUser, isTyping),
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper function for status text
  String _buildOnlineText(UserModel user, bool typing) {
    if (typing) {
      return "typing...";
    } else if (user.isOnline == true) {
      // Explicitly check for true
      return "online";
    } else if (user.lastSeen != null) {
      return 'last seen ${timeago.format(user.lastSeen!.toDate())}';
    } else {
      return "Offline";
    }
  }

  showPhotoOptions(ConversationViewModel viewModel, var user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text("Camera"),
              onTap: () {
                sendMessage(viewModel, user, imageType: 0, isImage: true);
                Navigator.pop(context); // Close the sheet
              },
            ),
            ListTile(
              title: const Text("Gallery"),
              onTap: () {
                sendMessage(viewModel, user, imageType: 1, isImage: true);
                Navigator.pop(context); // Close the sheet
              },
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return chatRef
        .doc(documentId)
        .collection('messages')
        .orderBy('time',
            descending:
                true) // Order descending to use reverse: true in ListView
        .snapshots();
  }
}
