import 'package:animations/animations.dart'; 
import 'package:flutter/cupertino.dart';       
import 'package:flutter/material.dart';       
import 'package:ionicons/ionicons.dart';     
import 'package:nurox_chat/components/fab_container.dart'; 
import 'package:nurox_chat/pages/notification.dart';       
import 'package:nurox_chat/pages/profile.dart';           
import 'package:nurox_chat/pages/search.dart';             
import 'package:nurox_chat/pages/feeds.dart';              
import 'package:nurox_chat/utils/firebase.dart';          

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState(); // Création de l'état de l'écran
}

class _TabScreenState extends State<TabScreen> {
  int _page = 0; // Index de la page actuellement affichée

  // Liste des onglets avec titre, icône, widget de page et index
  List pages = [
    {
      'title': 'Home',
      'icon': Ionicons.home,
      'page': Feeds(), // Page principale (flux)
      'index': 0,
    },
    {
      'title': 'Search',
      'icon': Ionicons.search,
      'page': Search(), // Page de recherche
      'index': 1,
    },
    {
      'title': 'add Post/Story',
      'icon': Ionicons.add_circle,
      'page': '', // Vide car on utilise un bouton flottant
      'index': 2,
    },
    {
      'title': 'Notification',
      'icon': CupertinoIcons.bell_solid,
      'page': Activities(), // Page notifications
      'index': 3,
    },
    {
      'title': 'Profile',
      'icon': CupertinoIcons.person_fill,
      'page': Profile(profileId: firebaseAuth.currentUser!.uid), // Page profil de l'utilisateur actuel
      'index': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Corps principal : page affichée avec transition animée
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,                // Animation principale
            secondaryAnimation: secondaryAnimation, // Animation secondaire
            child: child,                        // Page enfant
          );
        },
        child: pages[_page]['page'], // Page affichée selon l'onglet sélectionné
      ),
      
      // Barre de navigation inférieure
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface, // Couleur selon thème
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 5),
            
            // Boucle sur chaque onglet
            for (Map item in pages)
              if (item['index'] == 2)
                // Si index = 2 → bouton flottant pour ajouter post/story
                buildFab()
              else if (item['index'] == 3)
                // Si index = 3 → notifications avec badge dynamique
                StreamBuilder<int>(
                  stream: streamNumberOfNotifications(), // Flux du nombre de notifications
                  builder: (context, snapshot) {
                    final int notificationCount = snapshot.data ?? 0; // Nombre de notifications
                    
                    // Icône notification
                    final notificationIcon = Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: IconButton(
                        icon: Icon(
                          item['icon'],
                          color: item['index'] != _page
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black
                              : Theme.of(context).colorScheme.secondary,
                          size: 25.0,
                        ),
                        onPressed: () => navigationTapped(item['index']), // Naviguer vers la page
                      ),
                    );

                    // Badge rouge si notifications > 0
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        notificationIcon,
                        if (notificationCount > 0)
                          Positioned(
                            right: 0,
                            top: 5,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red, // Fond rouge pour badge
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                notificationCount.toString(), // Affiche le nombre
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    );
                  },
                )
              else // Autres onglets → simple icône
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: IconButton(
                    icon: Icon(
                      item['icon'],
                      color: item['index'] != _page
                          ? Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black
                          : Theme.of(context).colorScheme.secondary,
                      size: 25.0,
                    ),
                    onPressed: () => navigationTapped(item['index']), // Naviguer vers la page
                  ),
                ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  // Widget pour le bouton flottant
  buildFab() {
    return Container(
      height: 45.0,
      width: 45.0,
      child: FabContainer(
        icon: Ionicons.add_outline, // Icône "+"
        mini: true,
      ),
    );
  }

  // Changer la page active
  void navigationTapped(int page) {
    setState(() {
      _page = page;
    });
  }

  // Flux en temps réel du nombre de notifications
  Stream<int> streamNumberOfNotifications() {
    return notificationRef
        .doc(firebaseAuth.currentUser!.uid) // Document utilisateur
        .collection('notifications')         // Sous-collection notifications
        .snapshots()                         // Écoute en temps réel
        .map((snapshot) {
          return snapshot.docs.length;       // Nombre de notifications
        });
  }
}
