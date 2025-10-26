import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurox_chat/models/enum/message_type.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

//  Classe Message : représente un message échangé entre deux utilisateurs
class Message {
  //  Attributs
  String? content; // Contenu du message (texte ou URL d’image)
  String? senderUid; // Identifiant unique de l’expéditeur
  String? messageId; // Identifiant unique du message
  MessageType? type; // Type du message : texte ou image
  Timestamp? time; // Date et heure d’envoi du message (Firestore Timestamp)

  //  Constructeur
  Message({
    this.content,
    this.senderUid,
    this.messageId,
    this.type,
    this.time,
  });

  //  Constructeur nommé : créer un objet Message à partir d’un JSON Firestore
  Message.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    senderUid = json['senderUid'];
    messageId = json['messageId'];
    // Déterminer le type du message à partir du texte stocké
    if (json['type'] == 'text') {
      type = MessageType.TEXT;
    } else {
      type = MessageType.IMAGE;
    }
    time = json['time'];
  }

  //  Méthode toJson() : convertir l’objet Message en JSON pour l’enregistrer dans Firestore
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['content'] = content;
    data['senderUid'] = senderUid;
    data['messageId'] = messageId;
    data['type'] = (type == MessageType.TEXT) ? 'text' : 'image';
    data['time'] = time;
    return data;
  }
}


