import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final lightTheme1 = ThemeData(
    colorScheme: ColorScheme.light(
      background: Colors.white,
      primary: const Color(0xff0054b5),
      secondary: Colors.grey[300]!,
    ),
    primaryColor: const Color(0xff0054b5),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xff0054b5),
        selectedItemColor: Color(0xff0054b5),
        unselectedItemColor: Color.fromARGB(255, 176, 176, 176),
        type: BottomNavigationBarType.shifting),
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xffffffff),
    textTheme: TextTheme(
        bodyMedium: GoogleFonts.firaSans().copyWith(color: Colors.black)),
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0,
      surfaceTintColor: Color.fromARGB(255, 255, 255, 255),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 2, color: Color(0xffF1F1F5))),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(width: 2, color: Color(0xff0054b5)),
      ),
      constraints: const BoxConstraints.expand(height: 48),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(width: 2, color: Color(0xff0054b5)),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints.tight(const Size.fromHeight(40)),
        ),
        menuStyle: const MenuStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(
              Color.fromARGB(255, 255, 255, 255)),
        )),
  );

  static final darkTheme2 = ThemeData(
    canvasColor: const Color(0xff1A3848),
    primaryColor: const Color(0xff0054b5),
    colorScheme: ColorScheme.dark(
        background: const Color(0xff0D1F29),
        primary: const Color(0xff98A2B3),
        secondary: Colors.grey[800]!),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xff0054b5),
      selectedItemColor:
          Color.fromARGB(255, 255, 255, 255), // Selected item color
      unselectedItemColor: Colors.grey, // Unselected item color
    ),
    scaffoldBackgroundColor: const Color(0xff1A3848),
    cardColor: const Color(0xff1A3848),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      surfaceTintColor: Color(0xff0054b5),
      shadowColor: Color(0xff0054b5),
      backgroundColor: Color(0xff0D1F29),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xff1A3848),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      constraints: const BoxConstraints.expand(height: 48),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(width: 2, color: Color(0xff2382AA)),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints.tight(const Size.fromHeight(40)),
        ),
        menuStyle: const MenuStyle(
          backgroundColor:
              MaterialStatePropertyAll<Color>(Color.fromARGB(255, 26, 56, 72)),
        )),
  );
}
