import 'package:flutter/material.dart';
import 'package:help_app/src/contact/settings_page.dart';
import 'package:provider/provider.dart';
import '/src/home/home_module.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

import 'home/home_page.dart';

const _backgroundColor = Color(0xFFededed);
const _foregroundColor = Colors.black;
const _errorColors = Colors.red;

ThemeData _buildHelpAppTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    colorScheme: _HelpAppColorScheme,
    toggleableActiveColor: Colors.black45,
    appBarTheme: AppBarTheme(elevation: 0.5),
    accentColor: _foregroundColor,
    primaryColor: _backgroundColor,
    buttonColor: Colors.black38,
    scaffoldBackgroundColor: _backgroundColor,
    cardColor: _backgroundColor,
    textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.black38),
    errorColor: _errorColors,
    buttonTheme: const ButtonThemeData(
      colorScheme: _HelpAppColorScheme,
      textTheme: ButtonTextTheme.normal,
    ),
    primaryIconTheme: _customIconTheme(base.iconTheme),
    textTheme: _buildHelpAppTextTheme(base.textTheme),
    primaryTextTheme: _buildHelpAppTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildHelpAppTextTheme(base.accentTextTheme),
    iconTheme: _customIconTheme(base.iconTheme),
  );
}

IconThemeData _customIconTheme(IconThemeData original) {
  return original.copyWith(color: _foregroundColor);
}

TextTheme _buildHelpAppTextTheme(TextTheme base) {
  return base
      .copyWith(
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          letterSpacing: 0.03,
        ),
        button: base.button.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.03,
        ),
      )
      .apply(
        displayColor: _foregroundColor,
        bodyColor: _foregroundColor,
      );
}

const ColorScheme _HelpAppColorScheme = ColorScheme(
  primary: Color(0xFF8b95a2),
  primaryVariant: _foregroundColor,
  secondary: Colors.black54,
  secondaryVariant: _foregroundColor,
  surface: _backgroundColor,
  background: _backgroundColor,
  error: _errorColors,
  onPrimary: _foregroundColor,
  onSecondary: _foregroundColor,
  onSurface: _foregroundColor,
  onBackground: _foregroundColor,
  onError: _backgroundColor,
  brightness: Brightness.light,
);

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routes = <String, WidgetBuilder>{
      HomePage.tag: (context) => HomePage(),
      '/home': (context) => HomePage(),
    };

    return ChangeNotifierProvider(
      create: (context) => MySettings(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _buildHelpAppTheme(),
          home: HomeModule(),
          routes: routes),
    );
  }
}
