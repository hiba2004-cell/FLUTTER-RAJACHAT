import 'package:flutter/cupertino.dart'; 
import 'package:flutter/material.dart';  
import 'package:provider/provider.dart'; 
import 'package:nurox_chat/view_models/theme/theme_view_model.dart'; 
class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState(); // Création de l'état
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    // Récupère le TextTheme actuel pour utiliser les styles du thème
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context); // Retour à l'écran précédent
          },
          child: Icon(Icons.keyboard_backspace), // Icône de retour
        ),
        title: Text(
          "Settings", // Titre de l'AppBar
        ),
      ),
      // Corps de la page avec padding
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            // Première option : About
            ListTile(
              title: Text(
                "About",
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w900, // Titre en gras
                ),
              ),
              subtitle: Text(
                "A Fully Functional Social Media Application Made by ISIC Team",
                style: textTheme.titleSmall, // Sous-titre avec style du thème
              ),
              trailing: Icon(Icons.error), // Icône à droite
            ),
            Divider(), // Ligne séparatrice

            // Deuxième option : Dark Mode
            ListTile(
              title: Text(
                "Dark Mode",
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w900, // Titre en gras
                ),
              ),
              subtitle: Text(
                "Use the dark mode",
                style: textTheme.titleSmall, // Sous-titre avec style du thème
              ),
              trailing: Consumer<ThemeProvider>(
                // Ecouteur du ThemeProvider pour basculer entre Dark et Light mode
                builder: (context, ThemeProvider notifier, child) => CupertinoSwitch(
                  onChanged: (val) {
                    notifier.toggleTheme(); // Appelle la fonction pour changer le thème
                  },
                  value: notifier.dark, // Etat actuel du thème
                  activeTrackColor: Theme.of(context).colorScheme.secondary, // Couleur active
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
