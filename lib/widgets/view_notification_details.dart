import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nurox_chat/models/notification.dart';
import 'package:nurox_chat/pages/profile.dart';
import 'package:nurox_chat/widgets/indicators.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewActivityDetails extends StatefulWidget {
  final ActivityModel? activity; // L'activité à afficher (like, commentaire, etc.)

  ViewActivityDetails({this.activity});

  @override
  _ViewActivityDetailsState createState() => _ViewActivityDetailsState();
}

class _ViewActivityDetailsState extends State<ViewActivityDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar simple avec bouton retour
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Retour à l'écran précédent
          },
          child: Icon(Icons.keyboard_backspace),
        ),
      ),
      // Corps principal de la page
      body: ListView(
        children: [
          buildImage(context), // Affiche l'image associée à l'activité
          // Affiche l'utilisateur et l'heure de l'activité
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            leading: GestureDetector(
              onTap: () {
                // Navigue vers le profil de l'utilisateur
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) =>
                        Profile(profileId: widget.activity!.userId),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 25.0,
                backgroundImage: NetworkImage(widget.activity!.userDp!),
              ),
            ),
            title: Text(
              widget.activity!.username!, // Nom de l'utilisateur
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Row(
              children: [
                Icon(Ionicons.alarm_outline, size: 13.0), // Icône d'heure
                SizedBox(width: 3.0),
                Text(
                  timeago.format(widget.activity!.timestamp!.toDate()),
                  // Affiche le temps écoulé depuis l'activité
                ),
              ],
            ),
          ),
          // Affiche le commentaire ou message associé à l'activité
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              widget.activity?.commentData ?? "",
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
          Divider(), // Ligne de séparation
        ],
      ),
    );
  }

  // Widget pour afficher l'image associée à l'activité
  buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0), // Coins arrondis
        child: CachedNetworkImage(
          imageUrl: widget.activity!.mediaUrl!, // URL de l'image
          placeholder: (context, url) {
            return circularProgress(context); // Affiche un loader pendant le téléchargement
          },
          errorWidget: (context, url, error) {
            return Icon(Icons.error); // Icône si l'image ne charge pas
          },
          height: 400.0,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}
