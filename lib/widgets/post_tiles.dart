import 'package:flutter/cupertino.dart'; 
import 'package:flutter/material.dart'; 
import 'package:nurox_chat/models/post.dart'; 
import 'package:nurox_chat/screens/view_image.dart'; 
// Widget pour afficher un post sous forme de vignette (tile)
class PostTile extends StatefulWidget {
  final PostModel? post; // Post à afficher

  PostTile({this.post}); // Constructeur

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    // GestureDetector permet de détecter les tap/clicks sur le widget
    return GestureDetector(
      onTap: () {
        // Navigation vers la page ViewImage pour afficher le post en plein écran
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => ViewImage(post: widget.post),
        ));
      },
      child: Container(
        height: 100, // Hauteur de la vignette
        width: 150, // Largeur de la vignette
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // Coins arrondis de la carte
          ),
          elevation: 5, // Ombre de la carte
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(3.0), // Coins arrondis de l'image
            ),
            // Affichage de l'image du post
            child: Image.asset(widget.post!.mediaUrl!.toString()),
          ),
        ),
      ),
    );
  }
}
