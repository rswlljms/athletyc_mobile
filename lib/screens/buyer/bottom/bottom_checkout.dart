import 'dart:convert';

import 'package:athletyc/models/product.dart';
import 'package:athletyc/screens/buyer/profile/order_success.dart';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class BottomCheckout extends StatelessWidget {
  final List<Product> cartItems;
   final double orderTotal; 
  //final Set<String> selectedProductIds;


  const BottomCheckout({
    super.key,
    required this.cartItems,
    required this.orderTotal
    //required this.selectedProductIds,
  });

    Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email'); // make sure you saved the email using this key
  }

  
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 1,
            ),
          ////CHECKOUT BUTTON
          SizedBox(width: 350, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.black,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
                  onPressed: () async {
                    final email = await getEmail();

                    if (email == null) {
                      Get.snackbar(
                        'Error',
                        'User not logged in.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return; // Stop here if email is null
                    }

                    final response = await http.post(
                     AppConfig.place_order,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'email': email,
                        'items': cartItems.map((item) => {
                          'product_id': item.id,
                          'quantity': item.cartQuantity,
                          'price': orderTotal,
                          'sellerID': item.sellerID,
                        }).toList(),
                      }),
                    );

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      if (data['success']) {
                        // Clear from cart here
                        await http.post(
                          AppConfig.remove_cart_items,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'email': email,
                            'product_ids': cartItems.map((item) => item.id).toList(),
                          }),
                        );

                        Get.snackbar(
                          'Checkout successfully',
                          'Please wait for the item to be approved by the seller.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderSuccessPage(orderId: data['order_id']),
                          ),
                        );
                      }
                      }  else {
                      Get.snackbar(
                          'Error',
                          'Failed to place order.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                    }
                  }, 
                  child: const Text('Place Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 16.0 / 2),
        ]
      ),
    );
  }
}