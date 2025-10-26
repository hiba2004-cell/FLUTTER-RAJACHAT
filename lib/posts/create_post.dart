import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:nurox_chat/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:nurox_chat/components/custom_image.dart';
import 'package:nurox_chat/models/user.dart';
import 'package:nurox_chat/utils/firebase.dart';
import 'package:nurox_chat/view_models/auth/posts_view_model.dart';
import 'package:nurox_chat/widgets/indicators.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  @override
  Widget build(BuildContext context) {
    currentUserId() {
      return firebaseAuth.currentUser!.uid;
    }

    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);
    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: viewModel.loading,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Ionicons.close_outline),
            onPressed: () {
              viewModel.resetPost();
              Navigator.pop(context);
            },
          ),
          title: Text(Constants.appName),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () async {
                await viewModel.uploadPosts(context);
                Navigator.pop(context);
                viewModel.resetPost();
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Post'.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            )
          ],
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          children: [
            SizedBox(height: 15.0),
            StreamBuilder(
              stream: usersRef.doc(currentUserId()).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  // print("This test : " + snapshot.data!.data().toString());
                  UserModel user = UserModel.fromJson(
                    snapshot.data!.data() as Map<String, dynamic>,
                  );
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25.0,
                      backgroundImage: AssetImage(user.photoUrl!),
                      backgroundColor: Colors.transparent,
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
                    ),
                  );
                }
                return Container();
              },
            ),
            InkWell(
              onTap: () => showImageChoices(context, viewModel),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: viewModel.imgLink != null
                    ? CustomImage(
                        imageUrl: viewModel.imgLink,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width - 30,
                        fit: BoxFit.cover,
                      )
                    : viewModel.mediaUrl == null
                        ? Center(
                            child: Text(
                              'Upload a Photo',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          )
                        : Image.file(
                            viewModel.mediaUrl!,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width - 30,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Post Caption'.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextFormField(
              initialValue: viewModel.description,
              decoration: InputDecoration(
                hintText: 'Eg. This is very beautiful place!',
                focusedBorder: UnderlineInputBorder(),
              ),
              maxLines: null,
              onChanged: (val) => viewModel.setDescription(val),
            ),
            SizedBox(height: 20.0),
            Text(
              'Location'.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0.0),
              title: Container(
                width: 250.0,
                child: TextFormField(
                  controller: viewModel.locationTEC,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0.0),
                    hintText: 'Maroc, El jadida!',
                    focusedBorder: UnderlineInputBorder(),
                  ),
                  maxLines: null,
                  onChanged: (val) => viewModel.setLocation(val),
                ),
              ),
              trailing: IconButton(
                tooltip: "Use your current location",
                icon: Icon(
                  CupertinoIcons.map_pin_ellipse,
                  size: 25.0,
                ),
                iconSize: 30.0,
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () => viewModel.getLocation(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showImageChoices(BuildContext context, PostsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // CALL THE NEW VIEWMODEL METHOD
                  viewModel.fetchImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  // CALL THE NEW VIEWMODEL METHOD
                  viewModel.fetchImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
