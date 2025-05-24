import 'package:athletyc/screens/buyer/home.dart';
import 'package:athletyc/screens/sign_in/login.dart';
//import 'package:athletyc/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('is_logged_in') ?? false; // Check if the user is logged in

  runApp(GetMaterialApp(
    title: 'Athletyc',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        labelStyle: TextStyle(color: Colors.white),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
        checkmarkColor: const Color.fromARGB(161, 237, 237, 237),
      ),
    ),
    home: isLoggedIn ? Homepage(user: {},) : Login(), // Navigate based on login status
    routes: {
      '/login': (context) => Login(),
      '/home': (context) => Homepage(user: {},),
    },
  ));
}
