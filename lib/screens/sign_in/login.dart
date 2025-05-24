
import 'package:athletyc/screens/sign_in/otp.dart';
import 'package:athletyc/utils/config.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

import 'package:athletyc/screens/sign_in/forgotpasssword.dart';
import 'package:athletyc/screens/sign_in/registration.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isObsecure = true.obs; //for password icon

  String emailError = '';
  String passwordError = '';

  //------FOR SENDING OTP
 Future<void> requestOtp(String email, BuildContext context) async {
  print("Sending OTP request for $email");

  final response = await http.post(
    AppConfig.send_otp,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  print("OTP response status: ${response.statusCode}");
  print("OTP response body: ${response.body}");
  
  if (response.statusCode == 200) {
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OtpVerify(email: email)),
    );
  } else {
    if (!context.mounted) return;
    Get.snackbar(
      'OTP Error',
      'Failed to send OTP. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}


//FOR LOGIN
 Future<Map<String, dynamic>> login(String email, String password) async {
    try{
      print("Sending login request...");
      final response = await http.post(
        //IP ADDRESS
        AppConfig.login,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

    print("Login response status: ${response.statusCode}");
    print("Login response body: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return {'success': true, 'user': data['user']};
    } else {
      var data = jsonDecode(response.body);
       return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  }catch (e) {
    return {'success': false, 'message': 'Error: $e'};
  }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 56.0, left: 24.0, bottom: 24.0, right: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //LOGO, TITLE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(width: 200, image: AssetImage('assets/image/ath1.png'),),
                  const SizedBox(height: 20.0 * 2,),
                  Text('Welcome back', textAlign: TextAlign.left, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600,)),
                  const SizedBox(height: 8.0,),
                  Text('Enter your details below', textAlign: TextAlign.left, style: TextStyle(fontSize: 16)),
                   const SizedBox(height: 30.0 * 2,),
                ],
              ),

              //FORM
              Form(
                key: formKey,
                child: FocusScope(
                  node: FocusScopeNode(),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //------EMAIL
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val == "" ? "Email is missing" : null, ///if no input of email
                  
                      decoration: InputDecoration(
                        hintText: "Email address",
                        errorText: emailError.isNotEmpty ? emailError : null,

                        contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 20),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Color.fromARGB(255, 193, 193, 193))),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                       ),
                    ),
                      const SizedBox(height: 16.0),
                  
                    //PASSWORD
                    Obx(
                      () =>  TextFormField(
                      controller: passwordController,
                      obscureText: isObsecure.value,
                      validator: (val) => val == "" ? "Password is missing" : null, ///password is not entered
                  
                  
                      decoration: InputDecoration(
                  
                          suffixIcon: Obx(
                            ()=> GestureDetector(
                              onTap: (){isObsecure.value = !isObsecure.value;},
                              child: Icon(
                                isObsecure.value ? Icons.visibility_off : Icons.visibility,
                                color: const Color.fromARGB(255, 86, 86, 86),
                              ),
                            )
                          ),
                  
                  
                        hintText: "Password",
                        errorText: passwordError.isNotEmpty ? passwordError : null,

                        contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 20),
                        enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Color.fromARGB(255, 193, 193, 193))),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                       ),
                    ),
                    ),
                      const SizedBox(height: 16.0),
                    
                    //FORGOT PASSWORD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword()),);}, 
                        child: const Text('Forgot Password?', textAlign: TextAlign.right, style: TextStyle(color: Colors.blue, fontSize: 16),)),
                      ],
                    ),
                  const SizedBox(height: 20.0,),
                   
                  //LOG IN BUTTON 
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
                    onPressed: () async {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      print("Login button pressed: email=$email, password=$password");

                      if (email.isEmpty || password.isEmpty) {
                        Get.snackbar(
                          "Error", 
                          "Please fill all required fields",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      var result = await login(email, password);

                      if (result['success']) {

                          Get.snackbar(
                            "Success", 
                            "We will send a verification code to you.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );

                          if (!mounted) return; 
                          print("Calling requestOtp...");
                          
                          
                          await requestOtp(email, context);
                        

                      } else {
                        Get.snackbar(
                            "Login Failed",
                            result['message'] ?? "Invalid email or password",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                      }
                    },
                    
                  child: Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16),),)),
                  const SizedBox(height: 16.0 / 2),
                  
                  //CREATE ACC
                  SizedBox(width: double.infinity, height: 50, child: OutlinedButton(style: OutlinedButton.styleFrom(backgroundColor: Colors.white, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const Registration()),);}, 
                  child: const Text('Create Account', style: TextStyle(color: Colors.black, fontSize: 16),),)),
                  const SizedBox(height: 16.0 / 2),
                                
                       
                  ],
                                ),
                ),)
            ],
          ),
        ),
      )
    );
  }
}