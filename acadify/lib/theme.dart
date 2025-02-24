import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1565C0); // Blue
  static const background =
      Color.fromARGB(255, 145, 209, 255); // Light Blue Background
  static const text = Colors.black;
}

ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: const Color.fromARGB(255, 168, 218, 254),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.text, fontSize: 18),
  ),
);
