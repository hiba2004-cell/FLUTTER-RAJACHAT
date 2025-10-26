import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurox_chat/auth/login/login.dart';
import 'package:nurox_chat/auth/register/register.dart';
import 'package:nurox_chat/utils/constants.dart';

// La classe Landing représente l’écran d’accueil (landing page) de l’application
class Landing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // structure de base d'une page
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          // Centre le contenu à la fois horizontalement et verticalement
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ClipRRect(
                    // Definie le rayon pour l'appliquer les bordures
                    borderRadius: BorderRadius.circular(30.0), // rayon de 20
                    child: Image.asset(
                      'assets/icon/logo.jpg', // image locale dans le dossier assets
                      height: 200.0,
                      width: 200.0,
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
            Text(
              Constants.appName, //Affiche le nom de l’application
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 22.0,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Ubuntu-Regular',
                  ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        //  Barre de navigation en bas
        color: Theme.of(context).colorScheme.surface,
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                // Détecte un clic et navigue vers la page Login
                onTap: () {
                  // Action exécutée quand on appuie sur le widget
                  Navigator.of(context).push(
                    // // Navigation vers une autre page et le retour si l'om desire
                    CupertinoPageRoute(
                      builder: (_) =>
                          Login(), // le builder retourne la page Login à afficher / _ designe un parametre non utiliser
                    ),
                  );
                },
                child: Container(
                  height: 45.0,
                  width: 130.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: Colors.grey),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Theme.of(context).primaryColor,
                        Constants.greenMid,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Action exécutée quand on appuie sur le widget
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) =>
                          Register(), // // Construit et affiche la page Register()
                    ),
                  );
                },
                child: Container(
                  height: 45.0,
                  width: 130.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: Theme.of(context).primaryColor),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Theme.of(context).primaryColor,
                        Constants.greenMid,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'SIGN UP',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
