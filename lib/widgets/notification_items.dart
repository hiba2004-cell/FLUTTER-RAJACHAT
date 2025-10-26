import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import 'package:nurox_chat/models/notification.dart'; 
import 'package:nurox_chat/pages/profile.dart'; 
import 'package:nurox_chat/utils/firebase.dart'; 
import 'package:nurox_chat/widgets/view_notification_details.dart'; 
import 'package:timeago/timeago.dart' as timeago; 
import 'package:nurox_chat/widgets/indicators.dart'; 

// Widget pour afficher une activité (like, follow, comment)
class ActivityItems extends StatefulWidget {
  final ActivityModel? activity; // Activité à afficher

  ActivityItems({this.activity}); // Constructeur

  @override
  _ActivityItemsState createState() => _ActivityItemsState();
}

class _ActivityItemsState extends State<ActivityItems> {
  @override
  Widget build(BuildContext context) {
    // Dismissible permet de supprimer l'activité en la glissant vers la gauche
    return Dismissible(
      key: ObjectKey("${widget.activity}"), // Clé unique pour le Dismissible
      background: stackBehindDismiss(), // Widget affiché derrière lors du swipe
      direction: DismissDirection.endToStart, // Sens du swipe (droite vers gauche)
      onDismissed: (v) {
        delete(); // Supprimer l'activité de Firestore
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        onTap: () {
          // Navigation vers Profile ou détails de l'activité selon le type
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => widget.activity!.type == "follow"
                  ? Profile(profileId: widget.activity!.userId)
                  : ViewActivityDetails(activity: widget.activity!),
            ),
          );
        },
        // Avatar utilisateur
        leading: widget.activity!.userDp!.isEmpty
            ? CircleAvatar(
                radius: 20.0,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Center(
                  child: Text(
                    '${widget.activity!.username![0].toUpperCase()}', // Première lettre du nom
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                radius: 20.0,
                backgroundImage: AssetImage(
                  '${widget.activity!.userDp!}', // Image locale de l'utilisateur
                ),
                backgroundColor: Colors.transparent,
              ),
        // Texte de l'activité (nom + action)
        title: RichText(
          overflow: TextOverflow.ellipsis, // Texte tronqué si trop long
          text: TextSpan(
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
            ),
            children: [
              TextSpan(
                text: '${widget.activity!.username!} ', // Nom de l'utilisateur
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              TextSpan(
                text: buildTextConfiguration(), // Action de l'activité (liked, commented, followed)
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
        // Timestamp relatif
        subtitle: Text(
          timeago.format(widget.activity!.timestamp!.toDate()),
        ),
        // Image du post si type like ou comment
        trailing: previewConfiguration(),
      ),
    );
  }

  // Widget affiché derrière le Dismissible (icône de suppression)
  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Theme.of(context).colorScheme.secondary,
      child: Icon(
        CupertinoIcons.delete,
        color: Colors.white,
      ),
    );
  }

  // Supprime l'activité de Firestore
  delete() {
    notificationRef
        .doc(firebaseAuth.currentUser!.uid)
        .collection('notifications')
        .doc(widget.activity!.postId)
        .get()
        .then((doc) => {
              if (doc.exists)
                {
                  doc.reference.delete(),
                }
            });
  }

  // Retourne la preview du post si l'activité est un like ou un comment
  previewConfiguration() {
    if (widget.activity!.type == "like" || widget.activity!.type == "comment") {
      return buildPreviewImage(); // Affiche l'image du post
    } else {
      return Text(''); // Sinon rien
    }
  }

  // Détermine le texte à afficher selon le type d'activité
  buildTextConfiguration() {
    if (widget.activity!.type == "like") {
      return "liked your post";
    } else if (widget.activity!.type == "follow") {
      return "is following you";
    } else if (widget.activity!.type == "comment") {
      return "commented '${widget.activity!.commentData}'";
    } else {
      return "Error: Unknown type '${widget.activity!.type}'"; // Cas d'erreur
    }
  }

  // Widget pour afficher l'image du post dans la notification
  buildPreviewImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: CachedNetworkImage(
        imageUrl: widget.activity!.mediaUrl!, // URL de l'image
        placeholder: (context, url) {
          return circularProgress(context); // Cercle de chargement pendant le téléchargement
        },
        errorWidget: (context, url, error) {
          return Icon(Icons.error); // Icône d'erreur si l'image ne charge pas
        },
        height: 40.0,
        fit: BoxFit.cover,
        width: 40.0,
      ),
    );
  }
}
