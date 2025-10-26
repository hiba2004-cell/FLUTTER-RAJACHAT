// Importation des packages nécessaires
import 'package:cloud_firestore/cloud_firestore.dart'; // Pour interagir avec Firestore (base de données en temps réel)
import 'package:flutter/cupertino.dart'; // Pour utiliser des widgets spécifiques à iOS (comme CupertinoPageRoute)
import 'package:flutter/material.dart'; // Widgets principaux de Flutter
import 'package:nurox_chat/chats/conversation.dart'; // Écran de conversation entre deux utilisateurs
import 'package:nurox_chat/models/enum/message_type.dart'; // Enumération définissant le type de message (texte, image, etc.)
import 'package:nurox_chat/models/user.dart'; // Modèle utilisateur (UserModel)
import 'package:nurox_chat/utils/firebase.dart'; // Références aux collections Firestore (usersRef, chatRef, etc.)
import 'package:timeago/timeago.dart'
    as timeago; // Pour afficher les dates sous forme “il y a 2 minutes”

// Widget représentant un élément d’une liste de discussions (un contact avec le dernier message)
class ChatItem extends StatelessWidget {
  // Déclaration des variables du widget
  final String?
      userId; // Identifiant unique de l’utilisateur avec qui la discussion existe
  final Timestamp? time; // Heure du dernier message envoyé
  final String? msg; // Contenu du dernier message
  final int? messageCount; // Nombre total de messages échangés
  final String? chatId; // Identifiant unique de la discussion (chat)
  final MessageType? type; // Type de message (texte ou image)
  final String? currentUserId; // Identifiant de l’utilisateur connecté

  // Constructeur
  ChatItem({
    Key? key,
    @required this.userId,
    @required this.time,
    @required this.msg,
    @required this.messageCount,
    @required this.chatId,
    @required this.type,
    @required this.currentUserId,
  }) : super(key: key);

  // Construction du widget principal
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Écoute en temps réel du document utilisateur (pour afficher ses infos à jour)
      stream: usersRef.doc('$userId').snapshots(),
      builder: (context, snapshot) {
        // Vérifie si les données de l’utilisateur sont disponibles
        if (snapshot.hasData) {
          // Récupération du document utilisateur
          DocumentSnapshot documentSnapshot =
              snapshot.data as DocumentSnapshot<Object?>;

          // Conversion du document Firestore en modèle UserModel
          UserModel user = UserModel.fromJson(
            documentSnapshot.data() as Map<String, dynamic>,
          );

          // Construction de l’élément de liste (contact + dernier message)
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 5.0), // Espacement interne du ListTile

            // Partie gauche : avatar de l’utilisateur
            leading: Stack(
              children: <Widget>[
                // Si l’utilisateur n’a pas de photo, on affiche la première lettre de son nom
                user.photoUrl == null || user.photoUrl!.isEmpty
                    ? CircleAvatar(
                        radius: 25.0, // Taille du cercle
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary, // Couleur de fond (thème)
                        child: Center(
                          child: Text(
                            '${user.username![0].toUpperCase()}', // Première lettre du nom
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: Colors.white, // Texte blanc
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      )
                    // Sinon, on affiche sa photo
                    : CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(
                            user.photoUrl!), // Image locale de l’utilisateur
                      ),

                // Petit indicateur d’état (en ligne / hors ligne)
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Bordure blanche autour du statut
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    height: 15,
                    width: 15,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          // Vert si l’utilisateur est en ligne, gris sinon
                          color: user.isOnline ?? false
                              ? Color(0xff00d72f)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        height: 11,
                        width: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Titre : nom de l’utilisateur
            title: Text(
              '${user.username}',
              maxLines: 1, // Une seule ligne (évite le débordement)
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold, // Texte en gras
                  ),
            ),

            // Sous-titre : dernier message (texte ou “IMAGE” si le message est une image)
            subtitle: Text(
              type == MessageType.IMAGE
                  ? "IMAGE"
                  : "$msg", // Affiche IMAGE si type = image
              overflow: TextOverflow.ellipsis, // Tronque si trop long
              maxLines: 2,
              style: Theme.of(context).textTheme.titleMedium!,
            ),

            // Partie droite : heure + compteur de messages non lus
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Aligne à droite
              children: <Widget>[
                SizedBox(height: 10),
                // Affiche la date/heure du dernier message
                Text(
                  "${timeago.format(time!.toDate())}", // Format : “il y a x minutes”
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: 11,
                      ),
                ),
                SizedBox(height: 5),
                // Appel à la fonction pour afficher le compteur
                buildCounter(context),
              ],
            ),

            // Action lors du clic sur la discussion : ouverture de la page Conversation
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    // Redirection vers la page de conversation avec l’utilisateur choisi
                    return Conversation(
                      userId: userId!,
                      chatId: chatId!,
                    );
                  },
                ),
              );
            },
          );
        } else {
          // Si aucune donnée, on affiche un espace vide
          return SizedBox();
        }
      },
    );
  }

  // Fonction pour construire le compteur de messages non lus
  buildCounter(BuildContext context) {
    return StreamBuilder(
      stream: messageBodyStream(), // Écoute en temps réel du document de chat
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          // Récupère le document Firestore du chat
          DocumentSnapshot snap = snapshot.data;

          // Vérifie si le champ “reads” existe dans le document
          final bool hasScore = snapshot.data!.data()!.containsKey('reads');

          // Si oui, récupère la map des lectures, sinon une map vide
          Map usersReads = hasScore ? snap.get('reads') ?? {} : {};

          // Nombre de messages lus par l’utilisateur courant
          int readCount = usersReads[currentUserId] ?? 0;

          // Différence entre total des messages et lus = messages non lus
          int counter = messageCount! - readCount;

          // Si aucun message non lu, ne rien afficher
          if (counter == 0) {
            return SizedBox();
          } else {
            // Sinon, afficher le compteur
            return Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondary, // Couleur du compteur
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: BoxConstraints(
                minWidth: 11,
                minHeight: 11,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 1, left: 5, right: 5),
                child: Text(
                  "$counter", // Affiche le nombre de messages non lus
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 14,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        } else {
          // Si aucune donnée, ne rien afficher
          return SizedBox();
        }
      },
    );
  }

  // Fonction pour écouter les changements dans le document du chat correspondant
  Stream<DocumentSnapshot> messageBodyStream() {
    return chatRef
        .doc(chatId)
        .snapshots(); // Retourne un flux en temps réel du document chat
  }
}
