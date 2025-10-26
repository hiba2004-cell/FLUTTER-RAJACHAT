import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nurox_chat/components/life_cycle_event_handler.dart';
import 'package:nurox_chat/landing/landing_page.dart';
import 'package:nurox_chat/screens/mainscreen.dart';
import 'package:nurox_chat/utils/constants.dart';
import 'package:nurox_chat/utils/providers.dart';
import 'package:nurox_chat/view_models/theme/theme_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //Initialisation du Firebase
  runApp(
    // Lancement de  l'application
    MyApp(),
  );
}

// Classe principale de l'application
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState(); //
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Si personne n'est connecté, currentUserId sera null
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  //  Déclare un objet qui gère les événements du cycle de vie
  late final LifecycleEventHandler _userService;

  @override
  void initState() {
    // On y initialise les ressources et on démarre les observations du cycle de vie.

    super.initState();

    //  Initialise ton gestionnaire d’événements avec l’ID utilisateur
    _userService = LifecycleEventHandler(currentUserId: currentUserId);

    WidgetsBinding.instance.addObserver(this);

    if (currentUserId != null) {
      // Appel asynchrone sans 'await' exécution en tâche de fond
      // Bonne pratique pour les mises à jour de présence non critiques
      _userService.updateOnlineStatus(currentUserId!, true);
    }
  }

  @override
  void dispose() {
    //  Appelée quand le widget est retiré de l’arbre (ex. fermeture app ou déconnexion)
    if (currentUserId != null) {
      //  l'appel de la methode async non bloqunte sans await
      _userService.updateOnlineStatus(currentUserId!, false);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Contient plusieurs providers
      providers: providers,
      child: Consumer<ThemeProvider>(
        // Permet l'ecout du provider theme
        builder: (context, ThemeProvider themeProvider, Widget? child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeData(
              themeProvider.dark ? Constants.darkTheme : Constants.lightTheme,
            ),
            home: StreamBuilder<User?>(
              // l'ecout en temps reel de l'etat de l'utilisateur
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((BuildContext context, AsyncSnapshot<User?> snapshot) {
                if (snapshot.hasData) {
                  // Retourne true s'il contient data et false sinon
                  return TabScreen();
                } else
                  return Landing();
              }),
            ),
          );
        },
      ),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(
        theme.textTheme, // l'ajour du font au texte
      ),
    );
  }
}
