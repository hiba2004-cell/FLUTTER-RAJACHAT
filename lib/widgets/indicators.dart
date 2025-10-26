import 'package:flutter_spinkit/flutter_spinkit.dart'; 
import 'package:flutter/material.dart'; 
// Widget pour afficher un cercle de chargement animé centré
Center circularProgress(context) {
  return Center(
    child: SpinKitFadingCircle(
      size: 40.0, // Taille du cercle
      color: Theme.of(context).colorScheme.secondary, // Couleur basée sur le thème actuel
    ),
  );
}

// Widget pour afficher une barre de progression linéaire
Container linearProgress(context) {
  return Container(
    child: LinearProgressIndicator(
      valueColor:
          AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary), // Couleur animée basée sur le thème
    ),
  );
}
