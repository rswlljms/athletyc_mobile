import 'dart:async';
import 'dart:convert';

import 'package:athletyc/screens/buyer/home.dart';
import 'package:athletyc/screens/sign_in/login.dart';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerify extends StatefulWidget{
  
  final String email;
  
  
  const OtpVerify({super.key, required this.email});

  @override
  State<OtpVerify> createState() => _OtpVerify();
}

class _OtpVerify extends State<OtpVerify>{

  int resendCooldown = 60;
  int otpExpiry = 180;
  Timer? cooldownTimer;
  Timer? expiryTimer;
  Timer? resendTimer;
  Timer? otpExpiryTimer;
  bool canResend = false;
  bool otpExpired = false;


  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  
  //SUBMITTING OTP
    Future<void> verifyOtp(String email, String otp) async {
      final response = await http.post(
        AppConfig.verify_otp,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (otpExpired) {
        Get.snackbar(
          "OTP Expired", 
          "Please request a new code.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final user = json['user'];

        if (user == null) {
          // Handle error, user data missing in response
          print('User data missing from OTP verify response');
          return;
        }

         // Save user session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('email', email);
        await prefs.setString('buyer_id', user['id_no'].toString());

        Get.off(() => Homepage(user: {},)); // or your next screen
      } else {
         Get.snackbar(
          "Error", 
          "Invalid OTP",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    
    //--------FOR OTP BOXES
    Widget _buildOTPField(int index) {
        return Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: otpControllers[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: "",
              ),
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  FocusScope.of(context).nextFocus(); // Move to next field
                }
                else
                {
                   // Auto-submit when last digit is entered
                  String otp = otpControllers.map((c) => c.text).join();
                  if (otp.length == 6) {
                     if (otpExpired) {
                         Get.snackbar(
                          'OTP Expired',
                          'Your OTP has expired. Please request a new one.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                    verifyOtp(widget.email, otp);
                  }
                }
              }
            ),
        );
        }

          
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


  @override
  void initState() {
    super.initState();
    startResendCooldown();
    startOtpExpiryCountdown();
  }

    void resendOtp() async {
    await requestOtp(widget.email, context);
    startResendCooldown();
    startOtpExpiryCountdown();
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    otpExpiryTimer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }


  void startResendCooldown() {
    resendCooldown = 60;
    canResend = false;

    cooldownTimer?.cancel();
    cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (resendCooldown == 0) {
        setState(() {
          canResend = true;
          cooldownTimer?.cancel();
        });
      } else {
        setState(() => resendCooldown--);
      }
    });
  }

  void startOtpExpiryCountdown() {
    otpExpiry = 180;
    otpExpired = false;

    expiryTimer?.cancel();
    expiryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (otpExpiry == 0) {
        setState(() {
          otpExpired = true;
        });
        timer.cancel();
        Get.snackbar(
          'OTP Expired',
          'Your OTP has expired. Please request a new one.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        setState(() => otpExpiry--);
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);}, icon: Icon(Icons.arrow_back)),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 80, right: 32.0, left: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Enter Verification Code',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold, fontSize: 22)),
            SizedBox(height: 12),
            Text('We have sent a verification code to your email.',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            
            SizedBox(height: 62),

            


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, _buildOTPField),
            ),
            SizedBox(height: 62),
            SizedBox(width: double.infinity, height: 50, child: OutlinedButton(style: OutlinedButton.styleFrom(backgroundColor: Colors.black, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                  //----OTP
                  onPressed: () {
                   String otp = otpControllers.map((controller) => controller.text).join();
                    if (otp.length == 6 && !otpExpired) 
                    {
                      verifyOtp(widget.email, otp);
                    } 
                    else if (otp.length == 6 && otpExpired){
                      Get.snackbar(
                        'OTP Expired',
                        'Your OTP has expired. Please request a new one.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );

                    }
                    else {
                      Get.snackbar(
                          "Invalid OTP", 
                          "Please enter all 6 digits",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                    }
                  }, 
                  
                  child: const Text('Verify', style: TextStyle(color: Colors.white, fontSize: 16),),)),
            
            SizedBox(height: 16),
           //OTP EXPIRATION
            Text(
              otpExpired 
                ? "OTP expired"
                : "Expires in ${formatTime(otpExpiry)}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: otpExpired ? Colors.red : Colors.black,
              ),
            ), 

             SizedBox(height: 12),
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Request a new code in ', style: TextStyle(fontSize: 12)),
              if (!canResend)
                Text('$resendCooldown sec', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              if (canResend)
                GestureDetector(
                  onTap: resendOtp,
                  child: Text('here', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
            ],
          ),

          ],
        ),
      ),
    );
  }
}