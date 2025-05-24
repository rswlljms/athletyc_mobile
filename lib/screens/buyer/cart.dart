import 'dart:convert';

import 'package:athletyc/models/product.dart';
import 'package:athletyc/screens/buyer/bottom/navigation_menu.dart';
import 'package:athletyc/screens/buyer/bottom/bottom_cart.dart';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget{
   @override
  CartState createState() => CartState();
}


class CartState extends State<Cart> {
  bool isChecked = false;
  int quantity = 1;
  bool isLoading = true;
  String? email;
  List<Product> cartItems = [];


  Set<String> selectedProductIds = {};
  double totalPrice = 0.0;

//CHECKOUT
  // Method to handle checkbox changes
 void _onCheckboxChanged(bool? value, String productId, double productPrice) {
  setState(() {
    final item = cartItems.firstWhere((item) => item.id == productId);

    if (value == true) {
      selectedProductIds.add(productId);
      totalPrice += item.price * item.cartQuantity;
    } else {
      selectedProductIds.remove(productId);
      totalPrice -= item.price * item.cartQuantity;

      // 🔁 Reset totalPrice to 0 if no items are selected
      if (selectedProductIds.isEmpty) {
        totalPrice = 0.0;
      }
    }
  });
}


  // Update Cart Quantity and Total Price
  void updateCartQty(String productId, int newQty) {
    setState(() {
      // Find the product in the cart and update its quantity
      final item = cartItems.firstWhere((item) => item.id == productId);

      // Recalculate total price by removing the old item's total and adding the new one
      totalPrice -= item.price * item.cartQuantity;  // Remove old quantity price
      item.cartQuantity = newQty;  // Update the quantity
      totalPrice += item.price * newQty;  // Add new quantity price
      item.cartQuantity = newQty;
    });

    // Call the API to update the quantity on the backend
    updateCartQuantityOnBackend(productId, newQty);
  }


  Future<void> updateCartQuantityOnBackend(String productId, int newQty) async {
    // Example HTTP request to update quantity on the backend
    final response = await http.post(
      AppConfig.updateCartQty,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'product_id': productId, 'quantity': newQty, 'email': 'user_email@example.com'}),  // Replace email accordingly
    );

    if (response.statusCode != 200) {
      // Optional: show error/snackbar if update fails
      print("Failed to update quantity");
    }
  }

  @override
  void initState() {
    super.initState();
    loadEmailAndFetchCart();
  }


  Future<void> loadEmailAndFetchCart() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    await fetchCartItems();
  }


  Future<void> fetchCartItems() async {
  setState(() => isLoading = true);

  final response = await http.get(
    AppConfig.showCart(email!),
    
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    setState(() {
      cartItems = data.map((json) => Product.fromJson(json)).toList();
      isLoading = false;
    });
  } else {
    setState(() => isLoading = false);
  }
}



   void updateCartAfterChange() {
    // Call this after add/update/remove actions
    fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //leading: IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const Homepage()),);}, icon: Icon(Icons.arrow_back)),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Cart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        ),
        ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty ?  Center(
            child: Text(
              'No items in the cart',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 32),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];

                    return Dismissible(
                      key: Key(item.id), 
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                       
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Remove Item"),
                            content: Text("Are you sure you want to remove this item from your cart?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
                              TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Remove")),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        final productId = item.id;
                        
                        setState(() {
                          cartItems.removeAt(index);
                        });

                        await deleteFromCart(productId);  // DELETE ITEM NASA BABA
                      },
                      child: buildCartItem(item),  // FULL CART DETAILS NASA BABA
                    );},
                ),
              ),
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomCart(
            selectedProductIds: selectedProductIds,
            totalPrice: totalPrice, cartItems: cartItems,
          ),
          NavigationMenu(),
        ],
      ),
    );
  }




//DELETE ITEM FROM CART
  Future<void> deleteFromCart(String productId) async {
  final response = await http.post(
    AppConfig.deleteFromCart,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'product_id': productId}),
  );

  if (response.statusCode != 200) {
    // Optional: show an error
    print("Failed to delete from cart");
  }
}




//FULL CART DETAILS
  Row buildCartItem(Product item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: selectedProductIds.contains(item.id),  // Check if the item is selected
          onChanged: (value) => _onCheckboxChanged(value, item.id, item.totalPrice),

          checkColor: Colors.white,
          activeColor: Colors.black,
          side: const BorderSide(color: Color.fromARGB(255, 67, 67, 67), width: .5),
        ),

        // Dynamic image from backend
        //Uri
        Image.network(
          AppConfig.fullImageUrl(item.imageUrl!), // image path from backend
          width: 130,
          height: 130,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported),
        ),

        const SizedBox(width: 24),

        // PRODUCT DETAILS
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),

              Text("P${item.price}",
                  style: const TextStyle(fontSize: 12)),

              const SizedBox(height: 10),

              Text("Stocks left: ${item.qty}", style: const TextStyle(fontSize: 11)),

              if (item.color.isNotEmpty)
              Text("Color: ${item.color}", style: const TextStyle(fontSize: 11)),
              if (item.size.isNotEmpty)
              Text("Size: ${item.size}", style: const TextStyle(fontSize: 11)),
              

              const SizedBox(height: 10),

              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(2),
                ),
                height: 32,
                width: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (item.cartQuantity > 1) {
                          updateCartQty(item.id, item.cartQuantity - 1);
                        }
                      },
                      child: const Icon(Icons.remove, size: 14),
                    ),
                    Text('${item.cartQuantity}', style: const TextStyle(fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        if (item.cartQuantity < item.qty) {
                          updateCartQty(item.id, item.cartQuantity + 1);
                        }
                      },
                      child: const Icon(Icons.add, size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}