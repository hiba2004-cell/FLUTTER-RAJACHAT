import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  // App related strings
  static String appName = "RajaChat";

  static String avatarPlaceholder = 'assets/images/avatar.png';
  static String defaultBio = 'Hello there! I am using Raja Chat.';
  static String defaultImage = 'assets/images/login.png';

  // 🌿 Green gradient base colors
  static Color greenLight1 = const Color(0xFFB2F7EF);
  static Color greenLight2 = const Color.fromARGB(255, 126, 238, 134);
  static Color greenMid = const Color(0xFF2DC653);
  static Color greenDark1 = const Color(0xFF0EAD69);
  static Color greenDark2 = const Color(0xFF064635);


  // Colors for theme
  static Color lightPrimary = greenLight1;
  static Color darkPrimary = greenDark2;

  static Color lightAccent = greenMid;
  static Color darkAccent = greenDark1;

  static Color lightBG = const Color(0xFFF6FFF8);
  static Color darkBG = const Color(0xFF081C15);

  // 🌤️ Light Theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: greenMid,
    scaffoldBackgroundColor: lightBG,
    textSelectionTheme: TextSelectionThemeData(cursorColor: greenMid),

    // 💡 THE FIX FOR TEXT COLOR IN LIGHT THEME
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData.light().textTheme.apply(
            bodyColor:
                Colors.black, // Default color for most text in light mode
            displayColor: Colors.black, // Default color for headlines/displays
          ),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: lightBG,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.nunito(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      surface: lightBG,
      primary: greenMid,
      secondary: greenDark1,
      secondaryContainer: greenLight2,
    ),
    iconTheme: IconThemeData(color: greenMid),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: greenMid,
        foregroundColor: Colors.white,
      ),
    ),
  );

  // 🌙 Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: greenMid,
    scaffoldBackgroundColor: darkBG,
    textSelectionTheme: TextSelectionThemeData(cursorColor: greenMid),

    // 💡 THE FIX FOR TEXT COLOR IN DARK THEME
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white, // Default color for most text in dark mode
            displayColor: Colors.white, // Default color for headlines/displays
          ),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: darkBG,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.nunito(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      background: darkBG,
      surface: darkBG,
      primary: greenMid,
      secondaryContainer: greenDark2,
      secondary: greenDark1,
      brightness: Brightness.dark,
    ),
    iconTheme: IconThemeData(color: greenMid),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: greenMid,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }
}
