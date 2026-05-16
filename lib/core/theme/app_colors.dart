import 'package:flutter/material.dart';

class AppColors {
  static const Color greenDark = Color(0xFF00572E);
  static const Color greenPrimary = Color(0xFF00B242);
  static const Color cream = Color(0xFFF2F2D8);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF717184);
  static const Color blue = Color(0xFF0068C7);
  static const Color lightBlue = Color(0xFFB8DCFF);
  static const Color orange = Color(0xFFFF9300);
  static const Color yellow = Color(0xFFFFE473);
  static const Color gold = Color(0xFFFFAF00);
  static const Color red = Color(0xFFE80037);
  static const Color brown = Color(0xFFD2691E);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color screenBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF0D1711) : const Color(0xFFF1F4E0);
  }

  static Color cardBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF17241B) : white;
  }

  static Color subtleBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF203327) : const Color(0xFFF9FBF0);
  }

  static Color border(BuildContext context) {
    return isDark(context) ? const Color(0xFF2B4434) : const Color(0xFFE2E9D8);
  }

  static Color mutedText(BuildContext context) {
    return isDark(context) ? const Color(0xFFB6C4BA) : Colors.black54;
  }

  static Color primaryText(BuildContext context) {
    return isDark(context) ? const Color(0xFFEAF4EC) : black;
  }

  static Color greenText(BuildContext context) {
    return isDark(context) ? const Color(0xFF58E084) : const Color(0xFF0D5D33);
  }

  static Color greenIconBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF173D27) : const Color(0xFFE8F5E9);
  }
}
