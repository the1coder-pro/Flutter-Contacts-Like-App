import 'package:flutter/material.dart';
import '/src/home/home_module.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

import 'home/home_page.dart';

const _backgroundColor = Color(0xFFededed);
const _foregroundColor = Colors.black;
const _errorColors = Colors.red;

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    colorScheme: _shrineColorScheme,
    toggleableActiveColor: Colors.black45,
    appBarTheme: AppBarTheme(elevation: 0),
    accentColor: _foregroundColor,
    primaryColor: _backgroundColor,
    buttonColor: Colors.black38,
    scaffoldBackgroundColor: _backgroundColor,
    cardColor: _backgroundColor,
    textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.black38),
    errorColor: _errorColors,
    buttonTheme: const ButtonThemeData(
      colorScheme: _shrineColorScheme,
      textTheme: ButtonTextTheme.normal,
    ),
    primaryIconTheme: _customIconTheme(base.iconTheme),
    textTheme: _buildShrineTextTheme(base.textTheme),
    primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
    iconTheme: _customIconTheme(base.iconTheme),
  );
}

IconThemeData _customIconTheme(IconThemeData original) {
  return original.copyWith(color: _foregroundColor);
}

TextTheme _buildShrineTextTheme(TextTheme base) {
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

const ColorScheme _shrineColorScheme = ColorScheme(
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

// TODO: Edit here the colors for the DateTimeRange Picker colors
// TODO: AND EDIT IN THE THESE FILES: [edit_page.dart, add_page.dart]

// the HelpDuration radio button select is broken

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routes = <String, WidgetBuilder>{
      HomePage.tag: (context) => HomePage(),
    };

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _buildShrineTheme(),
        // ThemeData(
        //     brightness: Brightness.light,
        //     buttonColor: _foregroundColor,
        //     accentColor: _foregroundColor,
        //     primaryTextTheme:
        //         _buildAppTextTheme(ThemeData.light().primaryTextTheme),
        //     accentTextTheme:
        //         _buildAppTextTheme(ThemeData.light().accentTextTheme),
        //     textTheme: _buildAppTextTheme(ThemeData.light().textTheme),
        //     primaryColor: _foregroundColor,
        //     dialogBackgroundColor: Colors.white,
        //     colorScheme: ColorScheme.light(primary: Colors.black),
        //     cardColor: _backgroundColor,
        //     toggleableActiveColor: _foregroundColor,
        //     scaffoldBackgroundColor: _backgroundColor,
        //     errorColor: Colors.red[600],
        //     iconTheme: IconThemeData(color: _foregroundColor),
        //     // colorScheme: _dateRangePickerColorScheme,
        //     inputDecorationTheme: InputDecorationTheme(
        //         focusColor: _foregroundColor, hoverColor: _foregroundColor),
        //     appBarTheme: AppBarTheme(
        //         elevation: 0,
        //         iconTheme: IconThemeData(color: _foregroundColor),
        //         actionsIconTheme: IconThemeData(color: _foregroundColor),
        //         toolbarTextStyle: TextStyle(color: _foregroundColor),
        //         titleTextStyle: TextStyle(color: _foregroundColor),
        //         backgroundColor: _foregroundColor,
        //         foregroundColor: _foregroundColor)),
        // // primarySwatch: Colors.indigo,
        home: HomeModule(),
        routes: routes);
  }
}
