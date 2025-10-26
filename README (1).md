# 🔥🔥 RajaChat Social Media App  
<a href="www.linkedin.com/in/nadiri-hiba-71023826b">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/LinkedIn_icon.svg/2048px-LinkedIn_icon.svg.png" width="32" height="32" alt="LinkedIn">
</a>


RajaChat is a fully functional social media app with multiple features built with flutter and dart.

## Features

* Custom photo feed
* Post photo posts from camera or gallery
    * Like posts
    * Comment on posts
        * View all comments on a post
* Search for users
* Realtime Messaging and Sending images
* Deleting Posts
* Profile Pages
    * Change profile picture
    * Change username
    * Follow / Unfollow Users
    * Change image view from grid layout to feed layout
    * Add your own bio
* Notifications Feed showing recent likes / comments of your posts + new followers
* Swipe to delete notification
* Dark Mode Support
* Stories/Status
* Used Provider to manage state

## Screenshots

<div>
  see post in <a href="https://www.linkedin.com/posts/nadiri-hiba-71023826b_flutter-firebase-mobiledevelopment-activity-7387539175841103872-juEx?utm_source=share&utm_medium=member_desktop&rcm=ACoAAEIQdPwBLJqSTqM7WLU2kUDO9w8tD3GCu-Y">linkedIn</a>
</div>

## Installation

#### 1. [Setup Flutter](https://flutter.dev/docs/get-started/install)

#### 2. Clone the repo

#### 3. Setup the firebase app

- You'll need to create a Firebase instance. Follow the instructions
  at https://console.firebase.google.com.
- Once your Firebase instance is created, you'll need to enable Google authentication.

* Go to the Firebase Console for your new instance.
* Click "Authentication" in the left-hand menu
* Click the "sign-in method" tab
* Click "Email and Password" and enable it
* Create an app within your Firebase instance for Android, with package name com.yourcompany.news
* Run the following command to get your SHA-1 key:

```
keytool -exportcert -list -v \
-alias androiddebugkey -keystore ~/.android/debug.keystore
```

* In the Firebase console, in the settings of your Android app, add your SHA-1 key by clicking "Add
  Fingerprint".
* Follow instructions to download google-services.json
* place `google-services.json` into `/android/app/`.

- Firestore Plugin
    - https://pub.dartlang.org/packages/cloud_firestore



### Credit 
**Charly Keleb**
