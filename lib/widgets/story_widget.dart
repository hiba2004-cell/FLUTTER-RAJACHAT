import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; 
import 'package:nurox_chat/models/user.dart'; 
import 'package:nurox_chat/posts/story/status_view.dart'; 
import 'package:nurox_chat/utils/firebase.dart'; 
import 'package:nurox_chat/widgets/indicators.dart'; 

// Widget principal pour afficher les stories
class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Fetch the list of story documents the current user can see
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: storiesIcanSeeStream('${firebaseAuth.currentUser!.uid}'),
        builder: (context, snapshot) {
          // Affichage d'un loader si la connexion est en attente
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: circularProgress(context));
          }

          // Gestion des erreurs
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading stories: ${snapshot.error}'));
          }

          // Aucun document de story disponible
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SizedBox(height: 1.0);
          }

          // 1. Récupération de tous les documents
          List<DocumentSnapshot> allStatusDocs = snapshot.data!.docs;

          // 2. Extraction et déduplication des userId (propriétaires des stories)
          Set<String> uniqueOwnerIds = {};

          for (var doc in allStatusDocs) {
            String? ownerId;
            try {
              ownerId = doc['userId'] as String?; // Extraction sécurisée
            } catch (_) {
              // Ignorer les documents sans userId
            }

            if (ownerId != null) {
              uniqueOwnerIds.add(ownerId); // Ajout à l'ensemble pour déduplication
            }
          }

          // Conversion en liste pour ListView.builder
          List<String> storyOwnerIds = uniqueOwnerIds.toList();

          // Si aucune story valide après déduplication
          if (storyOwnerIds.isEmpty) {
            return const SizedBox(height: 1.0);
          }

          // Affichage de la liste horizontale des stories
          return Container(
            height: 100.0,
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              itemCount: storyOwnerIds.length,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final String storyOwnerId = storyOwnerIds[index];
                // Construction de l'avatar et du nom utilisateur
                return _buildStatusAvatar(storyOwnerId);
              },
            ),
          );
        },
      ),
    );
  }

  // Helper method: construit l'avatar et le nom de l'utilisateur pour la story
  Widget _buildStatusAvatar(String storyOwner) {
    return StreamBuilder<DocumentSnapshot>(
      stream: usersRef.doc(storyOwner).snapshots(), // Récupération des infos utilisateur
      builder: (context, snapshot) {
        // Si pas de données utilisateur, retourner un widget vide
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        DocumentSnapshot documentSnapshot = snapshot.data!;
        UserModel user =
            UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

        return Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  // Navigation vers l'écran complet du statut
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StatusScreen(
                        ownerId: storyOwner,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2.5,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(
                        user.photoUrl!, // Image de profil de l'utilisateur
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                user.username!, // Nom de l'utilisateur
                style: const TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Coupe le texte trop long
              )
            ],
          ),
        );
      },
    );
  }

  // Stream des stories visibles par l'utilisateur actuel
  Stream<QuerySnapshot> storiesIcanSeeStream(String uid) {
    return statusRef.where('whoCanSee', arrayContains: uid).snapshots();
    // Retourne uniquement les documents où l'utilisateur est dans le champ 'whoCanSee'
  }
}
