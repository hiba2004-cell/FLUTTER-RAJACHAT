// Importation des bibliothèques nécessaires
import 'package:cloud_firestore/cloud_firestore.dart'; // Permet d'interagir avec la base de données Firestore
import 'package:flutter/material.dart'; // Bibliothèque principale pour construire l'interface utilisateur Flutter
import 'package:flutter/cupertino.dart'; // Fournit des widgets de style iOS
import 'package:ionicons/ionicons.dart'; // Fournit des icônes supplémentaires pour l’interface
import 'package:nurox_chat/chats/recent_chats.dart'; // Écran affichant la liste des discussions récentes
import 'package:nurox_chat/models/post.dart'; // Modèle de données représentant un post
import 'package:nurox_chat/screens/view_image.dart'; // Écran permettant de visualiser une image
import 'package:nurox_chat/services/chat_service.dart'; // Service responsable de la gestion des discussions et messages
import 'package:nurox_chat/utils/constants.dart'; // Fichier contenant des constantes utilisées dans toute l’application
import 'package:nurox_chat/utils/firebase.dart'; // Fichier gérant la connexion et les références Firebase
import 'package:nurox_chat/widgets/indicators.dart'; // Contient les indicateurs de chargement personnalisés
import 'package:nurox_chat/widgets/story_widget.dart'; // Widget pour afficher les stories
import 'package:nurox_chat/widgets/userpost.dart'; // Widget pour afficher un post utilisateur

// Widget principal représentant le flux d'actualités (posts + stories)
class Feeds extends StatefulWidget {
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> with AutomaticKeepAliveClientMixin {
  // Clé globale pour gérer l'état du Scaffold
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Nombre de posts chargés à la fois
  int page = 5;

  // Indicateur de chargement lors du défilement
  bool loadingMore = false;

  // Contrôleur de défilement pour détecter quand l’utilisateur atteint la fin de la liste
  // ScrollController() est donné comme parametre a la listeView.builder()
  ScrollController scrollController = ScrollController();

  @override
  void initState() { //initialiser correctement le widget
    // Ajout d’un écouteur pour le défilement afin de charger plus de posts automatiquement
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          // Augmente le nombre de posts à charger
          page = page + 5;
          loadingMore = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Construction du Scaffold principal
    return Scaffold(
      key: scaffoldKey,

      // Barre d'application (AppBar)
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Supprime le bouton de retour automatique
        title: Text(
          Constants.appName, // Affiche le nom de l’application
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true, // Centre le titre de l’AppBar
        actions: [
          // Bouton pour accéder aux messages
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Ionicons.chatbubble_ellipses, // Icône de messagerie
                  color: Theme.of(context).primaryColor,
                  size: 30.0,
                ),

                // StreamBuilder pour écouter en temps réel le nombre de messages non lus
                StreamBuilder<int>(
                  stream:
                      ChatService().getNumberOfUnreadMessages(currentUserId()),
                  builder: (context, AsyncSnapshot<int?> snapshot) {
                    final int messagesCount = snapshot.data ?? 0;
                    print('messagesCount $messagesCount');

                    // Si aucun message non lu, on n’affiche rien
                    if (messagesCount == 0) {
                      return const SizedBox();
                    }

                    // Affiche un badge rouge avec le nombre de messages non lus
                    return Positioned(
                      right: -1,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          messagesCount > 99 ? '99+' : '$messagesCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
            onPressed: () {
              // Navigation vers l’écran des discussions
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => Chats(),
                ),
              );
            },
          ),
          const SizedBox(width: 20.0),
        ],
      ),

      // Corps principal du Scaffold
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,

        // Fonction de rafraîchissement manuel des posts 
        onRefresh: () =>
            postRef.orderBy('timestamp', descending: true).limit(page).get(),

        // Utilisation de FutureBuilder pour charger les posts depuis firebase
        child: FutureBuilder(
          future:
              postRef.orderBy('timestamp', descending: true).limit(page).get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var snap = snapshot.data;
              List docs = snap!.docs;

              // Liste principale défilante contenant les stories et les posts
              return ListView.builder(
                controller: scrollController, // Contrôle le défilement
                itemCount: docs.length + 1, // +1 pour le StoryWidget au début
                itemBuilder: (context, index) {
                  // Si c’est le premier élément, on affiche les stories
                  if (index == 0) {
                    return StoryWidget();
                  }

                  // Pour tous les autres éléments, on affiche les posts
                  int postIndex = index - 1;
                  PostModel post = PostModel.fromJson(docs[postIndex].data());

                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: UserPost(
                        post: post), // Affichage d’un post utilisateur
                  );
                },
              );
            }

            // Si les données sont en cours de chargement, affiche un indicateur circulaire
            else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: circularProgress(context));
            }

            // Si aucune donnée n’est trouvée
            else {
              return Center(
                child: Text(
                  'No Feeds', // Message lorsqu’il n’y a pas de posts
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Assure que l’état du widget est conservé lorsque l’utilisateur change d’onglet
  @override
  bool get wantKeepAlive => true;
}
