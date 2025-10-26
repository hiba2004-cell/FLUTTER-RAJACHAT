// Importation des packages nécessaires
import 'package:cached_network_image/cached_network_image.dart'; // Pour charger et mettre en cache les images réseau
import 'package:cloud_firestore/cloud_firestore.dart'; // Pour manipuler les données Firestore (Timestamp, etc.)
import 'package:flutter/material.dart'; // Widgets et thèmes principaux de Flutter
import 'package:flutter_chat_bubble/chat_bubble.dart'; // Fournit les bulles de chat personnalisables
import 'package:nurox_chat/components/text_time.dart'; // Widget personnalisé pour afficher le texte du temps
import 'package:nurox_chat/models/enum/message_type.dart'; // Enumération du type de message (texte, image, etc.)
import 'package:timeago/timeago.dart'
    as timeago; // Permet de formater les dates sous forme "il y a x minutes"

// Widget représentant une bulle de chat (message individuel)
class ChatBubbleWidget extends StatefulWidget {
  // Déclaration des variables finales (immuables)
  final String? message; // Contenu du message (texte ou URL)
  final MessageType? type; // Type du message (texte, image, etc.)
  final Timestamp? time; // Heure d’envoi du message
  final bool?
      isMe; // Indique si le message vient de moi ou de l’autre utilisateur

  // Constructeur de la classe ChatBubbleWidget
  ChatBubbleWidget({
    @required this.message,
    @required this.time,
    @required this.isMe,
    @required this.type,
  });

  @override
  _ChatBubbleWidgetState createState() =>
      _ChatBubbleWidgetState(); // Création de l’état du widget
}

// Classe d’état associée à ChatBubbleWidget
class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  // Fonction qui définit la couleur de la bulle selon si c’est moi ou mon contact
  Color? chatBubbleColor() {
    if (widget.isMe!) {
      // Si c’est mon message, utiliser la couleur secondaire du thème
      return Theme.of(context).colorScheme.secondary;
    } else {
      // Si c’est le message de l’autre
      if (Theme.of(context).brightness == Brightness.dark) {
        // En mode sombre : gris foncé
        return Colors.grey[800];
      } else {
        // En mode clair : gris clair
        return Colors.grey[200];
      }
    }
  }

  // Fonction qui détermine la couleur d’une réponse selon le thème (utile si on ajoute des réponses plus tard)
  Color? chatBubbleReplyColor() {
    if (Theme.of(context).brightness == Brightness.dark) {
      // Mode sombre → gris moyen
      return Colors.grey[600];
    } else {
      // Mode clair → gris très clair
      return Colors.grey[50];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Détermine l’alignement du message selon l’expéditeur (droite = moi, gauche = autre)
    final align =
        widget.isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align, // Aligne la bulle à gauche ou à droite
      children: <Widget>[
        // Widget principal représentant la bulle du message
        ChatBubble(
          elevation: 0.0, // Supprime l’ombre de la bulle
          margin: const EdgeInsets.all(3.0), // Espacement autour de la bulle
          padding: const EdgeInsets.all(5.0), // Espacement intérieur
          alignment: widget.isMe!
              ? Alignment.centerRight
              : Alignment.centerLeft, // Position à droite si c’est moi
          clipper: ChatBubbleClipper3(
            // Forme personnalisée de la bulle
            nipSize: 0, // Taille de la petite flèche (0 = pas visible)
            type: widget.isMe!
                ? BubbleType.sendBubble // Forme pour message envoyé
                : BubbleType.receiverBubble, // Forme pour message reçu
          ),
          backGroundColor:
              chatBubbleColor(), // Couleur définie selon l’expéditeur
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // La colonne prend uniquement la taille nécessaire
            mainAxisAlignment:
                MainAxisAlignment.start, // Aligne le contenu en haut
            children: <Widget>[
              Padding(
                // Espacement intérieur du contenu
                padding: EdgeInsets.all(widget.type == MessageType.TEXT
                    ? 10
                    : 0), // Si texte, ajoute du padding
                child: widget.type == MessageType.TEXT
                    ? Text(
                        // Si message texte
                        widget.message!, // Affiche le texte
                        style: TextStyle(
                          color: widget.isMe!
                              ? Colors.white // Texte blanc si c’est mon message
                              : Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .color, // Couleur par défaut sinon
                        ),
                      )
                    : Image.asset(
                        // Si message image (type différent)
                        "${widget.message}", // Chemin de l’image dans les assets
                        height: 200, // Hauteur de l’image
                        width: MediaQuery.of(context).size.width /
                            1.3, // Largeur proportionnelle à l’écran
                        fit: BoxFit.cover, // Remplissage sans déformation
                      ),
              ),
            ],
          ),
        ),
        // Affichage de la date/heure sous la bulle
        Padding(
          padding: widget.isMe!
              ? EdgeInsets.only(
                  right: 10.0,
                  bottom: 10.0,
                ) // Décalage à droite si c’est mon message
              : EdgeInsets.only(
                  left: 10.0,
                  bottom: 10.0,
                ), // Décalage à gauche sinon
          child: TextTime(
            // Widget personnalisé pour refresher chaque 1s
            child: Text(
              timeago.format(widget.time!
                  .toDate()), // Affiche le temps sous forme "il y a 2 min"
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .color, // Couleur du texte adaptée au thème
                fontSize: 10.0, // Taille du texte de l’heure
              ),
            ),
          ),
        ),
      ],
    );
  }
}
