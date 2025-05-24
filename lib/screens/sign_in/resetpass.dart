import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  final String token;

  const ResetPassword({super.key, required this.token});

  
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //HEADING
            Text("Password Reset Email Sent", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
            SizedBox(height: 8.0,),
            Text("We have sent the link to your email. Click the link to enter your new password.", style: TextStyle()),
            SizedBox(height: 20.0 * 2,),

           

            //SUBMIT BUTTON
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
              onPressed: (){}, 
            child: const Text("Done"),))
          ],
        ),
        ),
    );
  }
}
