import 'package:cloud_firestore/cloud_firestore.dart';

//  représente un commentaire dans Firestore
class CommentModel {
  // Attributs
  String? username; // Nom de l’utilisateur qui a commenté
  String? comment; // Contenu du commentaire
  Timestamp? timestamp; // Date et heure du commentaire (Firestore Timestamp)
  String? userDp; // URL ou chemin de la photo de profil de l’utilisateur
  String? userId; // Identifiant unique de l’utilisateur

  // Constructeur
  CommentModel({
    this.username,
    this.comment,
    this.timestamp,
    this.userDp,
    this.userId,
  });

  //  Constructeur nommé : crée un objet à partir d’un JSON Firestore
  CommentModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    comment = json['comment'];
    timestamp = json['timestamp'];
    userDp = json['userDp'];
    userId = json['userId'];
  }

  // Méthode de conversion : transforme un objet en JSON pour Firestore
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['username'] = username;
    data['comment'] = comment;
    data['timestamp'] = timestamp;
    data['userDp'] = userDp;
    data['userId'] = userId;
    return data;
  }
}
