import 'package:athletyc/models/product.dart';
import 'package:athletyc/screens/buyer/checkout.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BottomCart extends StatelessWidget {
  final List<Product> cartItems;
  final Set<String> selectedProductIds;
  final double totalPrice;

  BottomCart({
    required this.cartItems,
    required this.selectedProductIds,
    required this.totalPrice,
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
          /////TOTAL
          Text(
            'Total',
            style: TextStyle(fontSize: 11, color: Colors.black),
          ),

          Text(
            'P${totalPrice.toStringAsFixed(2)}', // Dynamically display the total price
            style: TextStyle(fontSize: 13, color: const Color.fromARGB(255, 38, 38, 176), fontWeight: FontWeight.w600),
          ),

          SizedBox(width: 10.0),


          ////CHECKOUT BUTTON
          SizedBox(width: 215, height: 45, 
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))), 
                 onPressed: selectedProductIds.isEmpty
                ? null  // Disable the button if no items are selected
                : () 
                
                {
                  final selectedProducts = cartItems
                    .where((product) => selectedProductIds.contains(product.id))
                    .toList();
                    // Proceed to checkout
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckoutPage(
                        selectedProducts: selectedProducts, // Pass selected items to checkout page
                        totalPrice: totalPrice, 
                      )),
                    );
                  },
          child: const Text('Checkout', style: TextStyle(color: Colors.white),),)),
          const SizedBox(height: 16.0 / 2),
        ]
      ),
    );
  }
}