import 'dart:convert';

import 'package:athletyc/models/product.dart';
import 'package:athletyc/screens/buyer/cart.dart';
import 'package:athletyc/screens/buyer/messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:athletyc/utils/config.dart';


class BottomAddToCart extends StatelessWidget {

  final Product productToCart;

  const BottomAddToCart({super.key, required this.productToCart});
  


  //ADD TO CART FROM PRODUCTDETAILS
  Future<void> _handleAddToCart(BuildContext context) async {
    
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null) {
      Get.snackbar(
          "Error",
          "You are not logged in.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      return;
    }

    final urlCart = AppConfig.addToCart;
    final int quantity = 1;


    //add to cart
    final response = await http.post(
      urlCart,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'product_id': productToCart.id, 
        'quantity': quantity,
      }),
    );

    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['cart_count'] != null) {
         Get.snackbar(
          "Added to cart successfully!",
          "Your item has been added to cart successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
         Get.snackbar(
          "Error",
          "Something went wrong.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
   } else {
      try {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${error['message']}'),
        ));
      } catch (e) {
        // This means the server response wasn't JSON
        print('Non-JSON error response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unexpected error: ${response.statusCode}'),
        ));
      }
    }
  }

  
  //BUY NOW FROM PRODUCTDETAILS
  Future<void> _handleBuyNow(BuildContext context) async {
    
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null) {
      Get.snackbar(
          "Error",
          "You are not logged in.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      return;
    }

    final urlCart = AppConfig.addToCart;
    final int quantity = 1;


    //add to cart
    final response = await http.post(
      urlCart,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'product_id': productToCart.id, 
        'quantity': quantity,
      }),
    );

    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['cart_count'] != null) {

        Navigator.push(context, MaterialPageRoute(builder: (context) => Cart()),);
      } else {
         Get.snackbar(
          "Error",
          "Something went wrong.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
   } else {
      try {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${error['message']}'),
        ));
      } catch (e) {
        // This means the server response wasn't JSON
        print('Non-JSON error response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unexpected error: ${response.statusCode}'),
        ));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 5.0,),
          InkWell(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final buyerIdString = prefs.getString('buyer_id') ?? '';
              final buyerId = int.tryParse(buyerIdString) ?? 0;


              print('buyerId from SharedPreferences: $buyerId');


              if (buyerId == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You must be logged in to send a message.')),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagePage(
                    sellerId: productToCart.sellerID, // Pass from product details
                    buyerId: buyerId,       // Get from SharedPreferences
                  ),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.mail_outline, color: Colors.black),
                SizedBox(height: 4),
                Text('Message', style: TextStyle(fontSize: 12, color: Colors.black)),
              ],
            ),
          ),


          ////ADD TO CART BUTTON
          SizedBox(width: 135, height: 45, child: ElevatedButton(style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))), 
                  
                  onPressed: () => _handleAddToCart(context), 
                  child: const Text('Add to Cart', style: TextStyle(color: Colors.black),),)
          ),

          ////BUY NOW BUTTON
          SizedBox(width: 135, height: 45, child: ElevatedButton(style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))), 
                  
                  onPressed: () => _handleBuyNow(context), 
                  child: const Text('Buy Now', style: TextStyle(color: Colors.white),),)
          ),
        ]
      ),
    );
  }
}