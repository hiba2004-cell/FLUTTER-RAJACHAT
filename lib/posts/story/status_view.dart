import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nurox_chat/models/status.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:nurox_chat/widgets/indicators.dart';
import 'package:story/story.dart';

class StatusScreen extends StatefulWidget {
  // Pass the ID of the user whose statuses we want to view
  final String ownerId;

  const StatusScreen({
    Key? key,
    required this.ownerId,
  }) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  // Stores the fetched list of StatusModel objects
  List<StatusModel> _statuses = [];

  //  Status View Tracker (to prevent multiple view increments on the same status)
  final Set<String> _viewedStatuses = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            Navigator.pop(context);
          }
        },
        child: FutureBuilder<QuerySnapshot>(
          // Fetch ALL status documents for the owner
          future: fetchOwnerStatuses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress(context);
            }

            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                  child: Text('Error loading stories: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text('No statuses found for this user.'));
            }

            // --- Data Processing ---
            _statuses = snapshot.data!.docs.map((doc) {
              return StatusModel.fromJson(doc.data() as Map<String, dynamic>);
            }).toList();

            return StoryPageView(
              // The entire list of statuses for ONE user is treated as ONE page.
              initialPage: 0,
              pageLength: 1, // One page for this user
              storyLength: (int pageIndex) => _statuses.length,

              indicatorPadding:
                  const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
              indicatorHeight: 5.0,
              onPageLimitReached: () {
                // This is called when the last story of the last page is reached.
                Navigator.pop(context);
                // 💡 If you wanted to navigate to the NEXT user's story group,
                //    you would trigger a callback here to the parent widget.
              },
              indicatorVisitedColor: Theme.of(context).colorScheme.secondary,
              indicatorDuration: const Duration(seconds: 8),

              itemBuilder: (context, pageIndex, storyIndex) {
                StatusModel stats = _statuses[storyIndex];

                // 4. Update View Count on status change (itemBuilder called)
                if (!_viewedStatuses.contains(stats.statusId)) {
                  _viewedStatuses.add(stats.statusId!);
                  // Update the document for this specific status
                  statusRef.doc(stats.statusId).update({
                    'viewers':
                        FieldValue.arrayUnion([firebaseAuth.currentUser!.uid])
                  });
                }

                // 5. Navigation Buttons Logic
                // We need the ownerIds list for navigation, but we don't have it here.
                // The parent screen that shows the avatar list should handle navigation BETWEEN users.
                // StoryPageView handles navigation BETWEEN statuses of this one user.

                // --- Story UI ---
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: getImage(stats.url!, context),
                        ),
                      ),

                      // Caption & View Count Footer
                      Positioned(
                        left: 0,
                        right: 0,
                        // Note: ownerId is used for comparison, not the dynamic userId used before
                        bottom: 50.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (stats.caption != null &&
                                stats.caption!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  stats
                                      .caption!, // Display the caption from the StatusModel
                                  textAlign: TextAlign.center,
                                  maxLines:
                                      3, // Limit the caption to a few lines
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 24.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Helper functions
  Widget getImage(String assetPath, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 17.0),
      child: SizedBox(
        height: 700,
        width: 700,
        child: Image.asset(
          assetPath, // The path defined in pubspec.yaml (e.g., 'assets/images/my_image.png')
          fit: BoxFit.fitHeight,

          errorBuilder: (context, error, stackTrace) {
            // Show the error icon if the asset cannot be found/loaded
            return const Center(child: Icon(Icons.error, color: Colors.white));
          },
        ),
      ),
    );
  }

  Future<QuerySnapshot> fetchOwnerStatuses() {
    // We order them by time to ensure proper sequence
    return statusRef
        .where('userId', isEqualTo: widget.ownerId)
        .orderBy('time', descending: false)
        .get();
  }
}
