import 'dart:convert';

import 'package:athletyc/screens/buyer/bottom/navigation_menu.dart';
import 'package:athletyc/screens/buyer/profile/completed.dart';
import 'package:athletyc/screens/buyer/profile/my_account.dart';
import 'package:athletyc/screens/buyer/profile/to_pay.dart';
import 'package:athletyc/screens/buyer/profile/to_rate.dart';
import 'package:athletyc/screens/buyer/profile/to_receive.dart';
import 'package:athletyc/screens/buyer/profile/to_ship.dart';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget{
   @override
  ProfileState createState() => ProfileState();
}


class ProfileState extends State<Profile> {

  Map<String, dynamic> accountDetails = {};
  bool isLoading = true;

  @override
    void initState() {
      super.initState();
      _loadEmailAndFetchAccount();

    }

   Future<void> _loadEmailAndFetchAccount() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    
    if (email != null) {
      await _fetchAccountDetails(email);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAccountDetails(String email) async {
    final response = await http.post(
      AppConfig.profile,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      setState(() {
        accountDetails = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error (e.g., show an alert)
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationMenu(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //leading: IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const Homepage()),);}, icon: Icon(Icons.arrow_back)),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top:24.0, bottom:24.0),
          child: Column(
            children: [
              //------CIRCULAR IMAGE
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      //padding: EdgeInsets.all(value),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 123, 123, 123),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        // child: Image(
                        //   fit: BoxFit.cover, 
                        //   image: AssetImage('assets/image/user/candidate-5.jpg'), 
                        //   color: Colors.black,
                        // ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(accountDetails['name'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.w600),),
                    Text(accountDetails['email'] ?? 'N/A', style: TextStyle(fontSize: 12),)
                  ],
                ),
              ),

              ///
              const SizedBox(height: 44),
              //----MY ACCOUNT
              GestureDetector(
                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MyAccount()),);},
                child: Row(
                  children: [
                    Expanded(child: Icon(Icons.person_outline)),
                    const SizedBox(width: 10),
                
                    Expanded(
                      flex: 5,
                      child: Text(
                        'My Account', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  
                      Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),

              //----TO PAY
              GestureDetector(
                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ToPay()),);},
                child: Row(
                  children: [
                    Expanded(child: Icon(Icons.payments_outlined)),
                    const SizedBox(width: 10),
                
                    Expanded(
                      flex: 5,
                      child: Text(
                        'To Pay', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  
                      Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),

               //----TO SHIP
              GestureDetector(
                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ToShip()),);},
                child: Row(
                  children: [
                    Expanded(child: Icon(Icons.local_shipping_outlined)),
                    const SizedBox(width: 10),
                
                    Expanded(
                      flex: 5,
                      child: Text(
                        'To Ship', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  
                      Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),

               //----TO RECEIVE
              GestureDetector(
                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ToReceive()),);},
                child: Row(
                  children: [
                    Expanded(child: Icon(Icons.local_mall_outlined)),
                    const SizedBox(width: 10),
                
                    Expanded(
                      flex: 5,
                      child: Text(
                        'To Receive', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  
                      Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),

               //----TO RATE
              GestureDetector(
                 onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ToRate()),);},
                child: Row(
                  children: [
                    Expanded(child: Icon(Icons.chat_bubble_outline)),
                    const SizedBox(width: 10),
                
                    Expanded(
                      flex: 5,
                      child: Text(
                        'To Rate', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  
                      Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
              ),

              
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),

               //----COMPLETED
              GestureDetector(
                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedPage()),);},
                child: Row(
                  children: [
                    Expanded(child: Icon(Icons.fact_check_outlined)),
                    const SizedBox(width: 10),
                
                    Expanded(
                      flex: 5,
                      child: Text(
                        'Completed', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  
                      Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),
               
               //----LOGOUT
              GestureDetector(
                onTap: (){
                  _showLogoutDialog(context);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: 
                      Icon(Icons.logout_outlined),
                    ),
                    const SizedBox(width: 10),
                
                    Expanded(
                      flex: 6,
                      child: Text(
                        'Logout', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red)),
                    ),
                   ],
                ),
              ),
              const SizedBox(height: 5),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: <Widget>[
          // No button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("No"),
          ),
          // Yes button
          TextButton(
            onPressed: () async{
              Navigator.of(context).pop(); // Close the dialog
              await logout(context);
              print("Logged out"); // Replace with actual logout functionality
            },
            child: Text("Yes"),
          ),
        ],
      );
    },
  );
}

  // Function to handle logout
  Future<void> logout(BuildContext context) async {
    // Clear user session data (e.g., auth token) from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // Clears all saved data including auth token

    // Navigate to the login screen after logout
    Navigator.pushReplacementNamed(context, '/login');  // Update the route as per your app
  }