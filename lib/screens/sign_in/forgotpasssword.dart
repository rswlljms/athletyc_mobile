import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:athletyc/utils/config.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final TextEditingController emailController = TextEditingController();

Future<void> sendResetLink() async {
  final email = emailController.text.trim();

  if (email.isEmpty) {
   Get.snackbar(
      "Error", 
      "Please enter your email",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  final response = await http.post(
    AppConfig.forgot_password,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  if (response.statusCode == 200) {
    Get.snackbar(
      "Success", 
      "",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } else {
    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    Get.snackbar(
      "Error", 
      "Something went wrong.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //HEADING
            Text("Forgot Password?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
            SizedBox(height: 10.0,),
            Text("No worries, we'll send you reset instructions.", style: TextStyle()),
            SizedBox(height: 20.0 * 2,),

            //TEXT FIELD
            Text("Email address", style: TextStyle()),
            SizedBox(height: 10.0,),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), hintText: "Enter your email"),
            ),
            SizedBox(height: 40.0 * 2,),

            //SUBMIT BUTTON
            SizedBox(width: double.infinity, height:50, child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
              onPressed: sendResetLink, 
            child: const Text("Send Reset Link", style: TextStyle(color: Colors.white, fontSize: 16))))
          ],
        ),
        ),
    );
  }
}
