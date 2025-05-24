import 'package:athletyc/models/product.dart';
import 'package:athletyc/screens/buyer/bottom/navigation_menu.dart';
import 'package:athletyc/screens/buyer/product_detail.dart';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Products extends StatelessWidget {
  final String prType;

  const Products({super.key, required this.prType});
  

//FOR TITLE NG CATEGORY
Future<List<Product>> fetchProductsByPrType(String prType) async {
  final response = await http.get(AppConfig.getProductsUri(prType));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationMenu(),
      body: 
      FutureBuilder<List<Product>>(
        future: fetchProductsByPrType(prType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data!;
          

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10.0),

                //------NAVIGATION BAR
                AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      const SizedBox(width: 16.0),
                      Image(width: 120, image: AssetImage('assets/image/ath1.png')),
                    ],
                  ),
                ),

                //----------SEARCH BAR
                const SizedBox(height: 26.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    height: 36.0,
                    width: 290,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                        const SizedBox(width: 6.0),
                      ],
                    ),
                  ),
                ),

                // CATEGORY TITLE
                Padding(
                  padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prType,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                        ),
                      ),

                      // PRODUCT GRID
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          itemCount: products.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                            mainAxisExtent: 360,
                          ),
                          itemBuilder: (_, index) => ProductBody(product: products[index],),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
}


/// PRODUCT BODY
class ProductBody extends StatelessWidget {
  final Product product;

  const ProductBody({ super.key, required this.product});

  // Maps prType values to folder names
  String mapPrTypeToFolder(String prType) {
    final map = {
      'Team Sports': 'TeamSports',
      'Water Sports': 'WaterSports',
      'Camping & Hiking': 'CampingHiking',
      'Biking': 'Biking',
      'Fitness Equipments': 'FitnessEquipments',
      'Sports Apparel': 'SportsApparel',
    };
    return map[prType] ?? 'Unknown';
  }


     // Replaces spaces and symbols with underscores for product name
    String sanitizeName(String name) {
      return name.toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '')  // remove non-word, non-space characters like &
      .replaceAll(RegExp(r'\s+'), '_'); 
    }

    // TO LOAD IMAGE OF CAROUSEL GET FROM DATABASE AND ASSET FOLDER 
    Widget loadProductImage(Product product) {
      String typeFolder = mapPrTypeToFolder(product.prType);
      String productFolder = sanitizeName(product.name);
      String assetPath = 'assets/image/$typeFolder/$productFolder/1.png';

      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        return Image.network(
          //IP ADDRESS Uri
          AppConfig.fullImageUrl(product.imageUrl!),

          fit: BoxFit.cover,width: 350,
                    height: 160,
          errorBuilder: (context, error, stackTrace) {
            // fallback to asset if network fails
            return Image.asset(
              assetPath,
              fit: BoxFit.cover,width: 250,
                    height: 150,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
            );
          },
        );
      } else {
        // fallback to asset directly if imageUrl is null
        return Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported),
        );
      }
    }




  // //ADD TO CART FROM PRODUCTDETAILS
  Future<void> _handleAddToCart(BuildContext context) async {
    
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null) {
      Get.snackbar("Error", "You are not logged in.", backgroundColor: Colors.red, colorText: Colors.white);
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
        'product_id': product.id, 
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



  @override
  Widget build(BuildContext context) {
    
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                ///--------GOING TO PRODUCT DETAILS
                GestureDetector(
                  onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetails(getproduct: product)),
                    );
                  },
                  child: Container(
                    // width: 250,
                    // height: 170,
                    //padding: const EdgeInsets.only(left: 28.0, right: 20.0),
                    child:  loadProductImage(product),
                ),)
              ],
            ),
          ),  //-----END 
    
    
        //----- PRODUCT DETAILS (NAME, PRICE)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Text(   //NAME
                  product.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 16.0/2),
              Row(
                children: [
                  Text(     //BRAND
                    product.brand,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(height: 16.0/2),
              Row(
                children: [
                /// PRICE
                  Text(
                  'P${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ],
            )
          ],
          ),
    
    
          //-----BUTTON
          Padding(
            padding: const EdgeInsets.only( top: 12.0),
            child: SizedBox(width: 155, height: 35, child: OutlinedButton(style: OutlinedButton.styleFrom(backgroundColor: Colors.black, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))), 
            onPressed: () => _handleAddToCart(context), 
            child: const Text('Add to Cart', style: TextStyle(color: Colors.white),),)),
          ),
        
      ],
    );
  }
}
