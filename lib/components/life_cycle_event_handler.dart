import 'package:cloud_firestore/cloud_firestore.dart'; // Importe la bibliothèque Firestore pour interagir avec la base de données Firebase
import 'package:flutter/material.dart'; // Importe le framework Flutter pour construire l’interface utilisateur
import 'package:nurox_chat/utils/firebase.dart'; // Importe un fichier utilitaire local contenant probablement la référence Firestore `usersRef`

// Classe LifecycleEventHandler : observe les changements de cycle de vie de l’application
class LifecycleEventHandler extends WidgetsBindingObserver {
  // Constructeur : prend en paramètre l’ID de l’utilisateur actuel
  LifecycleEventHandler({required this.currentUserId});

  // ID de l’utilisateur actuel (peut être nul si l’utilisateur n’est pas connecté)
  final String? currentUserId;

  // Méthode appelée automatiquement lorsque l’état du cycle de vie de l’application change
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si aucun utilisateur n’est connecté, on arrête la fonction
    if (currentUserId == null) return;

    // Variable pour déterminer si l’utilisateur est en ligne ou non
    bool isOnline;

    // Vérifie le nouvel état de l’application
    switch (state) {
      case AppLifecycleState.resumed:
        // L’application revient au premier plan → l’utilisateur est actif
        isOnline = true;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // L’application est minimisée, fermée ou masquée → l’utilisateur est hors ligne
        isOnline = false;
        break;
    }

    // Appelle la fonction asynchrone pour mettre à jour le statut sans bloquer l’interface
    updateOnlineStatus(currentUserId!, isOnline);
  }

  // Méthode asynchrone pour mettre à jour le statut de l’utilisateur dans Firestore
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    // Crée un dictionnaire contenant le nouveau statut
    Map<String, dynamic> data = {
      'isOnline': isOnline,
    };

    // Si l’utilisateur devient hors ligne, on met aussi à jour la dernière connexion
    if (!isOnline) {
      data['lastSeen'] = Timestamp.now();
    }

    try {
      // Met à jour le document de l’utilisateur dans la collection Firestore
      await usersRef.doc(userId).update(data);
    } catch (e) {
      // Affiche une erreur dans la console en cas d’échec
      print("Error updating online status for $userId: $e");
    }
  }
}
