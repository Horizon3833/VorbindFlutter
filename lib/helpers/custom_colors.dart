import 'package:flutter/material.dart';

class CustomColors{
  static const int darkGreyValue = 0xFF201A30;

  static const MaterialColor darkGrey = MaterialColor(
    darkGreyValue,
    <int, Color>{
      50: Color(0xFFE7E2EB),
      100: Color(0xFFC0B3C9),
      200: Color(0xFF967B9B),
      300: Color(0xFF6D438C),
      400: Color(0xFF4F256B),
      500: Color(darkGreyValue),
      600: Color(0xFF1C1430),
      700: Color(0xFF160F26),
      800: Color(0xFF110B1D),
      900: Color(0xFF0A0710),
    },
  );

}