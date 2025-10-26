// import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:ionicons/ionicons.dart';
import 'package:nurox_chat/chats/conversation.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/pages/profile.dart';
import 'package:nurox_chat/utils/constants.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:nurox_chat/widgets/indicators.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  User? user;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool loading = true;

  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  getUsers() async {
    QuerySnapshot snap = await usersRef.get();
    List<DocumentSnapshot> doc = snap.docs;
    users = doc;
    filteredUsers = users.where((doc) => doc.id != currentUserId()).toList();
    setState(() {
      loading = false;
    });
  }

  search(String query) {
    if (query == "") {
      List<DocumentSnapshot> users_without_me =
          users.where((doc) => doc.id != currentUserId()).toList();
      setState(() {
        filteredUsers = users_without_me;
        print(filteredUsers);
      });
    } else {
      List<DocumentSnapshot<Object?>> userSearch = users
          // 1. Convert to a List of Maps for easier access and filtering.
          //    We also exclude the current user's data right away.
          .map((userSnap) {
            // Safely cast the data to a Map<String, dynamic>
            final user = userSnap.data() as Map<String, dynamic>;

            // Store the snapshot and the map together to preserve the ID
            return {'snap': userSnap, 'data': user};
          })
          // 2. Filter the results based on both the query and the current user ID.
          .where((item) {
            final user = item['data'] as Map<String, dynamic>;
            final userSnap = item['snap'] as DocumentSnapshot;
            final userName = user['username'] as String;

            // EXCLUSION LOGIC: Skip if the user ID matches the current user's ID
            if (userSnap.id == currentUserId()) {
              return false;
            }

            // SEARCH LOGIC: Check if the username contains the query
            return userName.toLowerCase().contains(query.toLowerCase());
          })
          // 3. Map back to the original DocumentSnapshot list for the final state.
          .map((item) => item['snap'] as DocumentSnapshot)
          .toList();

      setState(() {
        filteredUsers = userSearch;
      });
    }
  }

  removeFromList(index) {
    filteredUsers.removeAt(index);
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          Constants.appName,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () => getUsers(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: buildSearch(),
            ),
            buildUsers(),
          ],
        ),
      ),
    );
  }

  Widget buildSearch() {
    // Access theme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            // 1. Set the light background to secondaryContainer
            decoration: BoxDecoration(
              // Use secondaryContainer for a subtle, tinted fill
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(28.0), // Modern pill shape
              // 2. Subtle shadow to lift the search bar
              boxShadow: [
                BoxShadow(
                  // Use onSurface for shadow color, but with very low opacity
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: 48.0, // Defined height for a good visual presence
              child: TextFormField(
                controller: searchController,
                // Style the input text using the appropriate theme color for contrast
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: colorScheme.onSecondaryContainer, fontSize: 16.0),
                textAlignVertical: TextAlignVertical.center,
                maxLength: 10,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                textCapitalization: TextCapitalization.sentences,
                // Functionality is preserved
                onChanged: (query) {
                  search(query);
                },
                decoration: InputDecoration(
                  // Add a prefix icon for clear communication
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Icon(
                      Icons.search,
                      // Use onSecondaryContainer for clear visibility against the background
                      color: colorScheme.onSecondaryContainer
                          .withValues(alpha: 0.7),
                      size: 20.0,
                    ),
                  ),
                  // Padding for vertical alignment
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  border: InputBorder.none, // Hide default border
                  counterText: '', // Hide character counter
                  hintText: 'Search...',
                  hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
            ),
          ),
        ),

        // Provides space for other elements in the Row, if any.
        const SizedBox(width: 10.0),

        // Optional: Placeholder for a trailing button/icon if needed.
        // Icon(Icons.mic, color: colorScheme.primary),
      ],
    );
  }

  buildUsers() {
    if (!loading) {
      if (filteredUsers.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              "No User Found",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        return Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot doc = filteredUsers[index];
                UserModel user =
                    UserModel.fromJson(doc.data() as Map<String, dynamic>);
                // print("my user is " + user.id.toString());
                return ListTile(
                  onTap: () => showProfile(context, profileId: user.id!),
                  leading: user.photoUrl!.isEmpty
                      ? CircleAvatar(
                          radius: 20.0,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: Center(
                            child: Text(
                              '${user.username![0].toUpperCase()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage(user.photoUrl!),
                        ),
                  title: Text(
                    user.username!,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user.email!,
                    style: Theme.of(context).textTheme.titleMedium!,
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => StreamBuilder(
                            stream: chatIdRef
                                .where(
                                  "users",
                                  isEqualTo: getUser(
                                    firebaseAuth.currentUser!.uid,
                                    doc.id,
                                  ),
                                )
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                var snap = snapshot.data;
                                List docs = snap!.docs;
                                print(snapshot.data!.docs.toString());
                                return docs.isEmpty
                                    ? Conversation(
                                        userId: doc.id,
                                        chatId: 'newChat',
                                      )
                                    : Conversation(
                                        userId: doc.id,
                                        chatId:
                                            docs[0].get('chatId').toString(),
                                      );
                              }
                              return Conversation(
                                userId: doc.id,
                                chatId: 'newChat',
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 30.0,
                      width: 62.0,
                      decoration: BoxDecoration(
                        // color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24.0, // A standard, readable icon size
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      return Center(
        child: circularProgress(context),
      );
    }
  }

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }

  //get concatenated list of users
  //this will help us query the chat id reference in other
  // to get the correct user id

  String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    var chatId = "${list[0]}-${list[1]}";
    return chatId;
  }

  @override
  bool get wantKeepAlive => true;
}
