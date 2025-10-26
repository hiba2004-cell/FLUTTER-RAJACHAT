import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nurox_chat/components/chat_item.dart';
import 'package:nurox_chat/models/message.dart';
import 'package:nurox_chat/services/chat_service.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:nurox_chat/widgets/indicators.dart';

// Widget stateless affichant la liste de toutes les conversations de l’utilisateur
class Chats extends StatelessWidget {
  // Service gérant les requêtes et flux de données liés aux chats (Firestore)
  final chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Barre d’application en haut ---
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            // Retour à l’écran précédent
            Navigator.pop(context);
          },
          child: Icon(Icons.keyboard_backspace),
        ),
        title: Text("Chats"), // Titre principal
      ),

      // --- Corps de la page : liste des chats ---
      body: StreamBuilder<QuerySnapshot>(
        // Écoute en temps réel de tous les chats de l’utilisateur connecté
        stream: chatService.userChatsStream('${firebaseAuth.currentUser!.uid}'),

        // Construction de l’interface selon l’état du flux
        builder: (context, snapshot) {
          // Si la connexion au flux est terminée (pas en attente)
          if (snapshot.connectionState != ConnectionState.waiting) {
            // Si aucune donnée n’a été reçue (aucun chat)
            if (!snapshot.hasData) {
              return Center(child: Text('No Chats'));
            }

            // Liste des documents (chats) récupérés depuis Firestore
            List chatList = snapshot.data!.docs;

            // Si la liste n’est pas vide
            if (chatList.isNotEmpty) {
              // --- Construction de la liste des conversations ---
              return ListView.separated(
                itemCount: chatList.length, // nombre de chats
                itemBuilder: (BuildContext context, int index) {
                  // Document Firestore représentant une conversation
                  DocumentSnapshot chatListSnapshot = chatList[index];

                  // Sous-Stream : écoute des messages de cette conversation
                  return StreamBuilder<QuerySnapshot>(
                    stream: chatService.messageListStream(chatListSnapshot.id),
                    builder: (context, snapshot) {
                      // Si le flux de messages contient des données
                      if (snapshot.hasData) {
                        // Liste de tous les messages du chat
                        List messages = snapshot.data!.docs;

                        // On prend le message le plus récent (messages.first)
                        Message message = Message.fromJson(
                          messages.first.data(),
                        );

                        // Liste des utilisateurs appartenant à cette conversation
                        List users = chatListSnapshot.get('users');

                        // On retire l’utilisateur connecté pour garder uniquement le destinataire
                        users.remove('${firebaseAuth.currentUser!.uid}');
                        String recipient = users[0];

                        // Retourne un widget affichant un élément de chat (ChatItem)
                        return ChatItem(
                          userId: recipient, // ID du correspondant
                          messageCount:
                              messages.length, // nombre total de messages
                          msg: message.content!, // dernier message envoyé
                          time: message.time!, // heure du dernier message
                          chatId: chatListSnapshot.id, // ID du chat Firestore
                          type:
                              message.type!, // type du message (texte, image…)
                          currentUserId: firebaseAuth
                              .currentUser!.uid, // utilisateur courant
                        );
                      } else {
                        // Si les données ne sont pas encore chargées
                        return SizedBox(); // widget vide
                      }
                    },
                  );
                },

                // Séparateur entre chaque conversation (ligne fine grise)
                separatorBuilder: (BuildContext context, int index) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 0.5,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Divider(),
                    ),
                  );
                },
              );
            } else {
              // Si aucun chat n’existe
              return Center(child: Text('No Chats'));
            }
          } else {
            // Pendant le chargement initial du flux
            return Center(child: circularProgress(context));
          }
        },
      ),
    );
  }
}
