
import 'dart:convert';

import 'package:athletyc/models/product.dart';
import 'package:athletyc/screens/buyer/bottom/navigation_menu.dart';
import 'package:athletyc/screens/buyer/product_detail.dart';
import 'package:athletyc/screens/buyer/products.dart';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:uni_links/uni_links.dart';

class Homepage extends StatelessWidget {
   final Map<String, dynamic> user; // <-- Accept user data

  Homepage({super.key, required this.user});
  

  
  //--------CIRCLE ICON CATEGORIES
  final List<Map<String, String>> categories = [
  {
    'title': 'Team Sports',
    'image': 'assets/image/TeamSports/team-sport.png',
  },
  {
    'title': 'Water Sports',
    'image': 'assets/image/WaterSports/water sport.jpg',
  },
  {
    'title': 'Sports Apparel',
    'image': 'assets/image/SportsApparel/apparel.png',
  },
  {
    'title': 'Fitness Equipments',
    'image': 'assets/image/FitnessEquipments/fitness.jpg',
  },
  {
    'title': 'Cycling & Biking',
    'image': 'assets/image/Biking/bikingimg.jpg',
  },
  {
    'title': 'Camping & Hiking',
    'image': 'assets/image/CampingHiking/outdoor.jpg',
  },
];

  Future<List<Product>> fetchProductsByType(String prType) async {
    final response = await http.get(
     AppConfig.getProductsByType(prType)
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['products'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationMenu(),
      body: SingleChildScrollView(
         child: Column(
          //padding: EdgeInsets.only( top: 30.0, left: 14.0, bottom: 54.0, right: 24.0,),
          //child: Column(
            children: [
              const SizedBox(height: 10.0),
              
              AppBar(
                automaticallyImplyLeading: false,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        //Image(width: 16, image: AssetImage('assets/icon/menu.png'),),
                        const SizedBox(width: 16.0),
                        Image(width: 120, image: AssetImage('assets/image/ath1.png'),),
                      ]
                    )
                  ],
                ),
                // actions: [
                //   IconButton(onPressed: (){}, icon: const Icon(Icons.search))
                // ],
                
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(image: AssetImage('assets/image/model1.png'),),
                  const SizedBox(height: 32.0),
                  Text("  Top Categories", style: TextStyle(fontWeight: FontWeight.w500, ),),
                  const SizedBox(height: 16.0),
                ],
              ),
                //-----CATEGORIES CIRCLE ICON
              SizedBox(
                height: 120,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: ( _,index){
                    final category = categories[index];
                    return CategoriesIcon(
                      image: category['image']!, 
                      title: category['title']!, 
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Products(prType: category['title']!)));
                      },); //nasa baba
                  },
                ),
              ),

              ProductSlider(prType: "Team Sports"),
              ProductSlider(prType: "Water Sports"),
              ProductSlider(prType: "Sports Apparel"),
              ProductSlider(prType: "Fitness Equipments"),
              ProductSlider(prType: "Cycling & Biking"),
              ProductSlider(prType: "Camping & Hiking"),


            ],
          ),
        ),
    );
  }
}



//-----CATEGORIES ICON CIRCLE
class CategoriesIcon extends StatelessWidget {
  const CategoriesIcon({
    super.key, 
    required this.image, 
    required this.title, 
    this.textColor = Colors.black, 
    this.backgroundColor = const Color.fromARGB(255, 244, 244, 244), 
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: Column(
          children: [
            //CICRLE ICON
            Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color:backgroundColor,
                shape: BoxShape.circle,
                //borderRadius: BorderRadius.circular(0),
              ),
              child: ClipOval(
                child: Image(image: AssetImage(image), fit:BoxFit.contain,height: 124,),
              ),
            ),
        
            //TEXT OF ICON
            const SizedBox(height: 16/2,),
            SizedBox(
              width: 75, 
              child: Text(
                title, 
               style: TextStyle(color: textColor,
                overflow: TextOverflow.ellipsis, fontSize: 12, fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              )
            ),
          ],
        ),
      ),
    );
  }
}


//-----CATEGORIES
class ProductSlider extends StatelessWidget {
  final String prType;

  const ProductSlider({super.key, required this.prType});

  Future<List<Product>> fetchProductsByType(String prType) async {
    final response = await http.get(
      AppConfig.getProductsByType(prType)
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['products'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: fetchProductsByType(prType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No products available'),
          );
        } else {
          final products = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30.0),
                Text(prType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height:15.0),
                SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return TeamSportsCard(
                        //uri
                        image: Image.network(
                          AppConfig.teamsports_image(product.imageUrl!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),

                        title: product.name,
                        price: "P${product.price}",
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetails(getproduct: product)));
                        },
                        onAddToCart: () => _handleAddToCart(context, product),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

  // //ADD TO CART FOR HOMEPAGE
  Future<void> _handleAddToCart(BuildContext context, Product product) async {
    
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

//-----CATEGORIES TEAM SPORTS 
class TeamSportsCard extends StatelessWidget {

  const TeamSportsCard({
    super.key, 
    required this.image,
    required this.title,
    required this.price,
    this.onTap,
    required this.onAddToCart,
  });
  final Widget image;
  final String title, price;
  final void Function()? onTap;
  final void Function() onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 4.0, left: 4.0),
        child: Column(
          children: [
            //THE PRODUCTS
            //IMAGE
            Container(
              width: 125,
              height: 125,
              padding: const EdgeInsets.only(right: 4.0, top: 4.0, bottom: 4.0),
              child: Center(
                child: image,
              ),
            ),
            const SizedBox(height: 6),

            //PRODUCT NAME & PRICE
            SizedBox(
              height:80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: const TextStyle(fontSize: 12),
                  ),
                   const SizedBox(height: 6),
                  SizedBox(
                    width: 125,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                ],
              ),
            ),
            const SizedBox(height: 10),
                
            
             //-----BUTTON
            SizedBox(width: 125, height: 35, child: OutlinedButton(style: OutlinedButton.styleFrom(backgroundColor: Colors.black, shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))), 
              onPressed: onAddToCart,
              child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 12),),)),
           
          ],
        ),
      ),
    );
  }
}
