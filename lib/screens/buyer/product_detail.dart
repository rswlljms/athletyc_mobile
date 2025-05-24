
import 'dart:convert';

import 'package:athletyc/models/product.dart';
import 'package:athletyc/screens/buyer/bottom/bottom_add_to_cart.dart';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readmore/readmore.dart';


class ProductDetails extends StatelessWidget {
  final Product getproduct;

  const ProductDetails({super.key, required this.getproduct});
  

  Future<List<ProductFeedback>> fetchFeedback(String product_id) async {
    final response = await http.get(AppConfig.get_feedback(product_id));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); 

    if (response.statusCode == 200) {
      final List<dynamic> feedbackJson = json.decode(response.body);
      return feedbackJson.map((json) => ProductFeedback.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load feedback');
    }
  }



  @override
  Widget build(BuildContext context) {

    final isColor = HelperFunctions.getColor('') != null;

    return Scaffold(
      bottomNavigationBar:BottomAddToCart(productToCart: getproduct,),
      body: SingleChildScrollView(
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                ///IMAGE SLIDER
                ProductImageSlider(getproduct: getproduct),
                
                /// PRICE AND TITLE
                Padding(
                    padding: EdgeInsets.only(right: 24.0, left: 24.0, bottom: 24.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            //TITLE
                            Text(getproduct.name, 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            ),
                            //BRAND
                            const SizedBox(height: 2.0,),
                            Text(getproduct.brand, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),),
                            //PRICE
                            const SizedBox(height: 12.0,),
                            Text(getproduct.price.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),),
                            
                        ],
                    ),
                ),

                /// STOCK ITEMS
                Padding(
                  padding: const EdgeInsets.only(right: 24.0, left: 24.0, bottom: 10.0),
                  child: Row(
                    children: [
                      Text('Stocks left:', 
                        style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis, 
                      ),
                      const SizedBox(width: 8.0,),
                      Text(getproduct.qty.toString(), 
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                /// COLOR
                Padding(
                  padding: const EdgeInsets.only(right: 24.0, left: 24.0, bottom: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// COLORS
                      // Text('Color', 
                      //     style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // SizedBox(height: 8),
                      
                    
                      // Wrap(
                      //   children: [ 
                      //     ChoiceChip(
                      //     label: isColor ? const SizedBox() : const Text(''), 
                      //     selected: true, 
                      //     onSelected: (value){},
                      //     labelStyle: TextStyle(color: Colors.white),
                      //     avatar: isColor ? Container(width: 50, height: 50) : null,
                      //     shape: isColor ? CircleBorder() : null,
                      //     labelPadding: isColor ? EdgeInsets.all(0) : null,
                      //     padding: isColor ? EdgeInsets.all(0) : null,
                      //     selectedColor:  isColor ? const Color.fromARGB(255, 142, 194, 236) : null,
                      //     backgroundColor: isColor ? Colors.blue : null,
                      //   ),
                      //   ]
                      // ),
                    ],
                  ),
                ),
                //---- END OF COLOR

                /// SIZE
                Padding(
                  padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Wrap(
                      spacing: 6,
                      children: getproduct.size.isNotEmpty
                          ? [
                            Text('Size', 
                              style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis, 
                            ),
                             const SizedBox(height: 8.0,),
                              ChoiceChip(
                                label: Text(getproduct.size), // Directly use the size string
                                selected: false,
                                onSelected: (value) {},
                                labelStyle: TextStyle(color: Colors.black),
                                avatar: isColor ? Container(width: 50, height: 50) : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: const BorderSide(color: Color.fromARGB(255, 56, 56, 56)), // black border
                                ),
                                labelPadding: EdgeInsets.only(right: 14, left: 14),
                                padding: isColor ? EdgeInsets.all(0) : null,
                                selectedColor: Colors.white,
                                backgroundColor: Colors.white,
                              ),
                            ]
                          : [],
                    )
                    ]
                  ),
                  ),
                ////----  END OF SIZE

                ///DESCRIPTION
                 Padding(
                  padding: const EdgeInsets.only(right: 24.0, left: 24.0, bottom: 24.0, top: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description', 
                        style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis, 
                      ),
                     SizedBox(height: 8),
                     
                     ReadMoreText(getproduct.prDesc,
                     trimLines: 2,
                     trimMode: TrimMode.Line,
                     trimCollapsedText: "Show More",
                     trimExpandedText: "Less",
                     moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                     lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                     )
                    ],
                  ),
                ),

              ///REVIEWS
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reviews', 
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),

                    FutureBuilder<List<ProductFeedback>>(
                      future: fetchFeedback(getproduct.id), // pass the correct product ID
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No reviews yet.');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: snapshot.data!.map((fb) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fb.user_id,
                                    style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 59, 59, 59))),
                                SizedBox(height: 4),
                                Text(fb.feedback,
                                    style: TextStyle(fontSize: 14, color: Colors.black)),
                                Divider(),
                              ],
                            ),
                          )).toList(),
                        );
                      },
                    )
                  ],
                ),
              )

            ],
         )
      )
    );
  }
}



/// PRODUCT IMAGE 
class ProductImageSlider extends StatelessWidget {
  final Product getproduct;

  const ProductImageSlider({
    super.key, required this.getproduct});

  
  String sanitizeFolderName(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]+'), '') // remove special characters
      .replaceAll(RegExp(r'\s+'), '_');    // replace spaces with underscores
}


  @override
  Widget build(BuildContext context) {
    return ClipPath(
        child: Container(
            color: Colors.white,
            child: Stack(
                children: [
                    /// MAIN IMAGE
                    SizedBox(height: 400, 
                    child: Center(
                      //Uri
                      child: Image.network(
                        AppConfig.fullImageUrl(getproduct.imageUrl!),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      )
                    ),
              
                    // /// IMAGE SLIDER / 3 IMAGES
                    // Positioned(
                    //     right: 0,
                    //     left: 25,
                    //     bottom: 30,
                    //     child: SizedBox(
                    //       height: 80,
                    //       child: ListView.separated(
                    //           separatorBuilder: (_,__) => const SizedBox(width: 12.0,), 
                    //           itemCount: imagePaths.length, 
                    //           //shrinkWrap: true,
                    //           scrollDirection: Axis.horizontal,
                    //           physics: const AlwaysScrollableScrollPhysics(),
                    //           itemBuilder: (_, index) {
                    //             return RoundedImage(imagePath: imagePaths[index]);
                    //           },
                    //     ),
                    //   ),
                    // ),
    
                    /// BACK ICON
                    AppBar(
                        backgroundColor: Colors.transparent,
                   )
                   
               
                ],
            ),
        ),
    );
  }
}

// /// FOR IMAGE SLIDER YUNG 3 IMAGES
// class RoundedImage extends StatelessWidget {

//   final String imagePath;

//   const RoundedImage({
//     super.key,
//     required this.imagePath,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//         onTap: (){},
//         child: Container(
//             //width: 80,
//             //padding: EdgeInsets.all(8.0),
//             decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(255, 204, 204, 204)), borderRadius: BorderRadius.circular(10)),
//             child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image.asset(
//                   imagePath,
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//                 ),
//             ),
//         ),
    
//     );
//   }
// }


// class CustomCurvedEdges extends CustomClipper<Path>{
//     @override
//     Path getClip(Size size) {
//         var path = Path();
//         path.lineTo(0, size.height);

//         final firstCurve = Offset(0, size.height - 20);
//         final lastCurve = Offset(30, size.height - 20);
//         path.quadraticBezierTo(firstCurve.dx, firstCurve.dy, lastCurve.dx, lastCurve.dy);

//         final secondFirstCurve = Offset(0, size.height - 20);
//         final secondLastCurve = Offset(size.height-30, size.height - 20);
//         path.quadraticBezierTo(secondFirstCurve.dx, secondFirstCurve.dy, secondLastCurve.dx, secondLastCurve.dy);

//         final thirdFirstCurve = Offset(size.width, size.height - 20);
//         final thirdLastCurve = Offset(size.width, size.height);
//         path.quadraticBezierTo(secondFirstCurve.dx, secondFirstCurve.dy, secondLastCurve.dx, secondLastCurve.dy);

//         path.lineTo(size.width, 0);
//         path.close();
//         return path;
//     }

//     @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }


/// FOR COLORS
class HelperFunctions{
  static Color? getColor(String value){

    if(value == "Blue"){
      return Color.fromARGB(255, 88, 175, 246);
    }
    else if (value == "White"){
      return Colors.white;
    }
     else if (value == "Black"){
      return Colors.black;
    } 
    else if (value == "Red"){
      return Colors.redAccent;
    }
     else if (value == "Pink"){
      return Colors.pinkAccent;
    }
  }
}