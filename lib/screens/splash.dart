import 'dart:async';
import 'package:athletyc/screens/sign_in/login.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    //_checkInitialLink();

    // Listen for dynamic links when app is already running
    // _sub = uriLinkStream.listen((Uri? uri) {
    //   _handleDeepLink(uri);
    // }, onError: (err) {
    //   print("Deep link error: $err");
    // });

    // Optionally show splash for 3 seconds before checking links
    Future.delayed(Duration(seconds: 3), () {
      // If no deep link found, still navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    });
  }

  // void _checkInitialLink() async {
  //   try {
  //     final initialUri = await getInitialUri();
  //     if (initialUri != null) {
  //       _handleDeepLink(initialUri);
  //     }
  //   } catch (e) {
  //     print("Failed to get initial URI: $e");
  //   }
  // }

  // void _handleDeepLink(Uri? uri) {
  //   if (uri != null &&
  //       uri.scheme == 'myapp' &&
  //       uri.host == 'reset_password' &&
  //       uri.pathSegments.isNotEmpty) {
  //     final token = uri.pathSegments.first;

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => ResetPassword(token: token)),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset('assets/image/ath1.png', width: 350, height: 300,),
          ),
      ),
    );
  }
}