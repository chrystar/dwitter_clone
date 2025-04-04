import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: XDarkThemeColors.primaryAccent,
  scaffoldBackgroundColor: XDarkThemeColors.primaryBackground,
  cardColor: XDarkThemeColors.cardBackground,
  hintColor: XDarkThemeColors.hintText,
  dividerColor: XDarkThemeColors.divider,
  colorScheme: ColorScheme.dark(
    primary: XDarkThemeColors.primaryAccent,
    secondary: XDarkThemeColors.primaryAccent,
    background: XDarkThemeColors.primaryBackground,
    surface: XDarkThemeColors.cardBackground,
    error: XDarkThemeColors.error,
    onPrimary: XDarkThemeColors.buttonText,
    onSecondary: XDarkThemeColors.buttonText,
    onBackground: XDarkThemeColors.primaryText,
    onSurface: XDarkThemeColors.primaryText,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: XDarkThemeColors.primaryText),
    bodyMedium: TextStyle(color: XDarkThemeColors.primaryText),
    bodySmall: TextStyle(color: XDarkThemeColors.secondaryText),
    displayLarge: TextStyle(color: XDarkThemeColors.primaryText),
    displayMedium: TextStyle(color: XDarkThemeColors.primaryText),
    displaySmall: TextStyle(color: XDarkThemeColors.primaryText),
    headlineLarge: TextStyle(color: XDarkThemeColors.primaryText),
    headlineMedium: TextStyle(color: XDarkThemeColors.primaryText),
    headlineSmall: TextStyle(color: XDarkThemeColors.primaryText),
    titleLarge: TextStyle(color: XDarkThemeColors.primaryText),
    titleMedium: TextStyle(color: XDarkThemeColors.primaryText),
    titleSmall: TextStyle(color: XDarkThemeColors.secondaryText),
    labelLarge: TextStyle(color: XDarkThemeColors.primaryText),
    labelMedium: TextStyle(color: XDarkThemeColors.secondaryText),
    labelSmall: TextStyle(color: XDarkThemeColors.secondaryText),
  ),
  iconTheme: const IconThemeData(color: XDarkThemeColors.iconColor),
  appBarTheme: const AppBarTheme(
    backgroundColor: XDarkThemeColors.secondaryBackground,
    titleTextStyle: TextStyle(
      color: XDarkThemeColors.primaryText,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: XDarkThemeColors.iconColor),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: XDarkThemeColors.secondaryBackground,
  ),
  // Add other theme configurations as needed (e.g., buttonTheme, inputDecorationTheme)
);