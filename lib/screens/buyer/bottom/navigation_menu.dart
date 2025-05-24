
import 'package:athletyc/screens/buyer/cart.dart';
import 'package:athletyc/screens/buyer/home.dart';
import 'package:athletyc/screens/buyer/messages.dart';
import 'package:athletyc/screens/buyer/profile/profile.dart';
import 'package:flutter/material.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,  // Center content horizontally
        children: [

          //HOME
          GestureDetector(
            onTap: () {
              // Navigate to Cart page without animation (instant page change)
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => Homepage(user: {},),
                  transitionDuration: Duration.zero,  // No transition, instant page change
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,  // Prevents the column from taking extra space
              crossAxisAlignment: CrossAxisAlignment.center,  // Center content horizontally in the column
              children: [
                Icon(Icons.home_outlined),  // Home icon
                SizedBox(height: 4),  // Space between icon and text
                Text('Home', textAlign: TextAlign.center),  // Home text
              ],
            ),
          ),


          //cart
          GestureDetector(
            onTap: () {
            // Navigate to Cart page without animation (instant page change)
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => Cart(),
                transitionDuration: Duration.zero,  // No transition, instant page change
              ),
            );
          },

            child: Column(
              mainAxisSize: MainAxisSize.min,  // Prevents the column from taking extra space
              crossAxisAlignment: CrossAxisAlignment.center,  // Center content horizontally in the column
              children: [
                Icon(Icons.shopping_bag_outlined),  // Home icon
                SizedBox(height: 4),  // Space between icon and text
                Text('Cart', textAlign: TextAlign.center),  // Home text
              ],
            ),
          ),



           //profile
          GestureDetector(
            onTap: () {
              // Navigate to Cart page without animation (instant page change)
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => Profile(),
                  transitionDuration: Duration.zero,  // No transition, instant page change
                ),
              );
            },

            child: Column(
              mainAxisSize: MainAxisSize.min,  // Prevents the column from taking extra space
              crossAxisAlignment: CrossAxisAlignment.center,  // Center content horizontally in the column
              children: [
                Icon(Icons.person_outline),  // Home icon
                SizedBox(height: 4),  // Space between icon and text
                Text('Profile', textAlign: TextAlign.center),  // Home text
              ],
            ),
          ),
        ],
      ),
    );
  }
}

