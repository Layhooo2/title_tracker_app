import 'package:flutter/material.dart';
ThemeData appThemeData(BuildContext context)
{
  return ThemeData(
    //
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.lightGreenAccent,
      brightness: Brightness.light,
      primaryContainer: Colors.lightGreen,
      tertiary: Colors.amber,
      tertiaryContainer: const Color.fromARGB(255, 220, 180, 80)
    ),
    useMaterial3: true,
    // scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
    ),
    //textTheme: Typography.whiteMountainView,
    fontFamily: 'CooperHewitt',
    iconTheme: const IconThemeData(
      color: Colors.lightGreen,
      size: 17,
    ),

  );
}