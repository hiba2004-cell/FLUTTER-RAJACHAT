import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; 
import 'package:nurox_chat/utils/firebase.dart'; 

// Widget affichant une icône avec un badge (nombre de notifications)
class IconBadge extends StatefulWidget {
  final IconData icon; // L'icône à afficher
  final double? size; // Taille de l'icône
  final Color? color; // Couleur de l'icône

  IconBadge({Key? key, required this.icon, this.size, this.color})
      : super(key: key);

  @override
  _IconBadgeState createState() => _IconBadgeState();
}

class _IconBadgeState extends State<IconBadge> {
  @override
  void initState() {
    super.initState(); // Initialisation de l'état
  }

  @override
  Widget build(BuildContext context) {
    // Stack permet de superposer le badge sur l'icône
    return Stack(
      children: <Widget>[
        // Icône principale
        Icon(
          widget.icon,
          size: widget.size,
          color: widget.color ?? null,
        ),
        // Badge affiché en haut à droite de l'icône
        Positioned(
          right: 0.0,
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.red, // Fond rouge pour le badge
              borderRadius: BorderRadius.circular(6), // Coins arrondis
            ),
            constraints: BoxConstraints(
              minWidth: 11, // Largeur minimale
              minHeight: 11, // Hauteur minimale
            ),
            child:
                Padding(padding: EdgeInsets.only(top: 1), child: buildCount()),
          ),
        ),
      ],
    );
  }

  // Fonction qui retourne le widget du compteur de notifications
  buildCount() {
    StreamBuilder(
      // Écoute des notifications Firestore en temps réel
      stream: notificationRef
          .doc(firebaseAuth.currentUser!.uid)
          .collection('notifications')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          QuerySnapshot snap = snapshot.data!;
          List<DocumentSnapshot> docs = snap.docs; // Liste des notifications
          return buildTextWidget(docs.length.toString()); // Affiche le nombre
        } else {
          return buildTextWidget(0.toString()); // Affiche 0 si pas de données
        }
      },
    );
  }

  // Widget Text pour afficher le nombre dans le badge
  buildTextWidget(String counter) {
    return Text(
      counter,
      style: TextStyle(
        color: Colors.white, // Texte en blanc
        fontSize: 9, // Taille du texte
      ),
      textAlign: TextAlign.center,
    );
  }
}
