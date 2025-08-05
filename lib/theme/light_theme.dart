import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFFF7F6FD);
const Color primaryAccent = Color(0xFF8EACCD);
const Color secondaryAccent = Color(0xFFB0C5A4);
const Color textColor = Color(0xFFEEC6CA);

class AppTheme {
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: backgroundColor,
      primary: primaryAccent,
      secondary: secondaryAccent,
    ),
    textTheme: TextTheme(bodyLarge: TextStyle(color: textColor)),
  );
}
