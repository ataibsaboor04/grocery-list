import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_list/screens/grocery_list.dart';
import 'package:grocery_list/splash_screen.dart';

final theme = ThemeData.light().copyWith(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    // brightness: Brightness.dark,
    seedColor: const Color.fromRGBO(255, 255, 21, 1),
    surface: const Color.fromARGB(255, 255, 255, 0),
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 234, 226, 181),
  textTheme: GoogleFonts.mooliTextTheme(), // mooliTextTheme
  appBarTheme: const AppBarTheme().copyWith(
      titleTextStyle: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Colors.black87,
  )),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Grocery List',
        theme: theme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/home': (context) =>
              const GroceryListScreen(title: 'Your Groceries'),
        });
  }
}
