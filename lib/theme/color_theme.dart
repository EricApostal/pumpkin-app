import 'dart:ui';
import 'package:flutter/material.dart';

class AppColorsDark {
  static const Color background = Color(0xFF14161A);
  static const Color foreground = Color(0xFF21252B);
  static const Color primary = Color(0xFF2448BE);
  static const Color secondary = Color(0xFF585F6A);
  static const Color tertiary = Color(0xFF333A44);
  static const Color dirtyWhite = Color(0xFFBDBDBD);
}

class ColorTheme {
  final Color background;
  final Color foreground;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color dirtywhite;

  final Color red;
  final Color green;
  final Color blue;
  final Color yellow;

  ColorTheme({
    required this.background,
    required this.foreground,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.dirtywhite,
    required this.red,
    required this.green,
    required this.blue,
    required this.yellow,
  });
}
