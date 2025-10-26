import 'dart:async'; // Importe la bibliothèque pour utiliser Timer

import 'package:flutter/material.dart'; // Importe Flutter pour construire l'UI

// Widget qui met à jour automatiquement son enfant toutes les secondes
class TextTime extends StatefulWidget {
  final Widget? child; // Enfant à afficher (widget à rafraîchir)

  const TextTime({this.child}); // Constructeur avec enfant optionnel

  @override
  _TextTimeState createState() => _TextTimeState(); // Crée l'état du widget
}

class _TextTimeState extends State<TextTime> {
  @override
  void initState() {
    super.initState();
    // Timer qui se déclenche toutes les secondes
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        // Vérifie que le widget est encore monté à l'écran
        setState(
            () {}); // Déclenche la reconstruction du widget pour mise à jour
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child!; // Retourne l'enfant du widget
  }
}
