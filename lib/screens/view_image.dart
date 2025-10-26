import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:nurox_chat/models/post.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewImage extends StatefulWidget {
  final PostModel? post; // Post à afficher

  ViewImage({this.post}); // Constructeur

  @override
  _ViewImageState createState() => _ViewImageState();
}

// Timestamp courant
final DateTime timestamp = DateTime.now();

// Fonction utilitaire pour récupérer l'ID de l'utilisateur courant
currentUserId() {
  return firebaseAuth.currentUser!.uid;
}

// Variable globale pour stocker un utilisateur
UserModel? user;

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    print("i am here now");
    return Scaffold(
      appBar: AppBar(), // Barre d'application vide
      body: SafeArea(
        child: Column(
          children: [
            // Image principale
            Expanded(
              child: Center(
                child: buildImage(
                    context), // Fonction qui construit le widget Image
              ),
            ),
            // Section utilisateur et like
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: SizedBox(
                height: 80.0,
                width: double.infinity,
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom d'utilisateur
                        Text(
                          widget.post!.username!,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3.0),
                        // Timestamp du post
                        Row(
                          children: [
                            const Icon(Ionicons.alarm_outline, size: 13.0),
                            const SizedBox(width: 3.0),
                            Text(
                              timeago.format(widget.post!.timestamp!
                                  .toDate()), // Affiche le temps relatif
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(), // Espace entre l'info utilisateur et le bouton like
                    buildLikeButton(), // Bouton like animé
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher l'image du post
  buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0), // Coins arrondis
          child: Image.asset(
            widget.post!
                .mediaUrl!, // Image locale (si URL distante, utiliser Image.network)
            height: 400.0,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width, // Largeur de l'écran
          )),
    );
  }

  // Ajouter une notification "like" si l'utilisateur n'est pas le propriétaire du post
  addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      // Récupérer les infos de l'utilisateur courant
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

      // Ajouter une notification dans la sous-collection de l'utilisateur propriétaire
      notificationRef
          .doc(widget.post!.ownerId)
          .collection('notifications')
          .doc(widget.post!.postId)
          .set({
        "type": "like",
        "username": user!.username!,
        "userId": currentUserId(),
        "userDp": user!.photoUrl,
        "postId": widget.post!.postId,
        "mediaUrl": widget.post!.mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  // Supprimer une notification "like" si l'utilisateur n'est pas le propriétaire
  removeLikeFromNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

      // Supprime la notification existante
      notificationRef
          .doc(widget.post!.ownerId)
          .collection('notifications')
          .doc(widget.post!.postId)
          .get()
          .then((doc) => {
                if (doc.exists) {doc.reference.delete()}
              });
    }
  }

  // Widget pour le bouton Like animé
  buildLikeButton() {
    return StreamBuilder(
      // Stream pour vérifier si l'utilisateur a déjà liké le post
      stream: likesRef
          .where('postId', isEqualTo: widget.post!.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

          // Fonction appelée lors du tap sur le bouton Like
          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              // Ajouter un like
              likesRef.add({
                'userId': currentUserId(),
                'postId': widget.post!.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification();
              return !isLiked;
            } else {
              // Supprimer le like
              likesRef.doc(docs[0].id).delete();
              removeLikeFromNotification();
              return isLiked;
            }
          }

          // Widget LikeButton animé
          return LikeButton(
            onTap: onLikeButtonTapped,
            size: 25.0,
            circleColor: CircleColor(
                start: Color(0xffFFC0CB),
                end: Color(0xffff0000)), // Couleur animation cercle
            bubblesColor: BubblesColor(
              dotPrimaryColor: Color(0xffFFA500),
              dotSecondaryColor: Color(0xffd8392b),
              dotThirdColor: Color(0xffFF69B4),
              dotLastColor: Color(0xffff8c00),
            ),
            likeBuilder: (bool isLiked) {
              // Icône du bouton selon l'état Like
              return Icon(
                docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                color: docs.isEmpty ? Colors.grey : Colors.red,
                size: 25,
              );
            },
          );
        }
        return Container(); // Retourne un container vide si le snapshot n'a pas encore de données
      },
    );
  }
}
