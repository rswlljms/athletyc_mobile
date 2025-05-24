import 'dart:convert';

import 'package:athletyc/models/product.dart';
import 'package:athletyc/models/userprofile.dart';
import 'package:athletyc/screens/buyer/bottom/bottom_checkout.dart';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final List<Product> selectedProducts;
  final double totalPrice;         // Receive total price

  CheckoutPage({required this.selectedProducts, required this.totalPrice});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
    UserProfile? userProfile;
    final double shippingFee = 79.0;
    double voucherDiscount = 0.0;


    // The original cart total (e.g., from items in cart)
    double originalTotal = 0.0;

    @override
    void initState() {
      super.initState();
      _loadProfile();
      _calculateCartTotal();
    }

    void _calculateCartTotal() {
    // Sample logic — replace with your actual calculation
    setState(() {
      originalTotal = widget.totalPrice; // Or however you get the base total
    });
  }

  double get orderTotal => originalTotal + shippingFee - voucherDiscount;

//CALCULATE VOUCHER DISCOUNT
  void _applyVoucherDiscount(double discount) {
    setState(() {
      voucherDiscount = discount;
    });
  }


    Future<void> _loadProfile() async {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final profile = await _fetchAccountDetails(email);
      setState(() {
        userProfile = profile;
      });
    }

  Future<UserProfile?> _fetchAccountDetails(String email) async {
    final response = await http.post(
      AppConfig.profile,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserProfile.fromJson(json);
    } else {
      print('Failed to fetch profile: ${response.statusCode}');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    final double orderTotal = widget.totalPrice + shippingFee - voucherDiscount;

    return Scaffold(
      bottomNavigationBar: BottomCheckout(cartItems: widget.selectedProducts, orderTotal: orderTotal,),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Order Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        ),
        
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 30, right: 20, bottom: 20),  
          
          child: Column(
            children: [
              ///-----ALL PRODUCT DETAILS OVERVIEW
              PrdOvrview(selectedProducts: widget.selectedProducts), ///nasa baba details

              const SizedBox(height: 24,),

              ///----VOUCHER FIELD
              VoucherFld(
                totalPrice: originalTotal + shippingFee,
                onDiscountApplied: _applyVoucherDiscount,
              ), ///nasa baba details

              const SizedBox(height: 24,),

              ///--TOTAL, PAYMENT, ADDRESS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 211, 211, 211)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top:15.0, left:14.0, right: 14.0, bottom: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SUBTOTAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: TextStyle(fontSize: 12)),
                          Text( 'P${widget.totalPrice.toStringAsFixed(2)}',
                           style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      //SHIPPING FEE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shipping Fee', style: TextStyle(fontSize: 12)),
                          Text('P${shippingFee.toStringAsFixed(2)}', 
                          style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                  
                      //VOUCHER DISCOUNT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Voucher Discount', style: TextStyle(fontSize: 12),),
                          Text('P${voucherDiscount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                  
                      //ORDER TOTAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Total', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('P${orderTotal.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Divider(),

                      const SizedBox(height: 12),

                      ///------PAYMENT METHOD
                      Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Cash on Delivery', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 12),

                      //--------SHIPPING ADDRESS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Shipping Address', style: TextStyle(fontWeight: FontWeight.w600)),
                          //Text('Change', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      //NAME OF BUYER
                      Text(userProfile?.name ?? 'Name not available',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                      const SizedBox(height: 4),

                      //NUMBER
                      Row(
                        children: [
                          Icon(Icons.call_outlined),
                          const SizedBox(width: 4),
                          Text(userProfile?.mobileNo ?? 'Number not available',
                          style: TextStyle(fontSize: 12)),
                        ],
                      ),

                      //ADDRESS
                      Row(
                        children: [
                          Icon(Icons.person_pin_circle_outlined,),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${userProfile?.region ?? ''}, ${userProfile?.province ?? ''}, ${userProfile?.city ?? ''}, ${userProfile?.brgy ?? ''}, ${userProfile?.street ?? ''}',
                              style: TextStyle(fontSize: 12),
                              maxLines: 3,
                            ),
                          ),
                        ],
                      )
                    ]
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}


//-----VOUCHER FIELD
class VoucherFld extends StatefulWidget {
  final double totalPrice;
  final Function(double) onDiscountApplied;

  const VoucherFld({
    Key? key,
    required this.totalPrice,
    required this.onDiscountApplied,
  }) : super(key: key);

  @override
  _VoucherFldState createState() => _VoucherFldState();
}

class _VoucherFldState extends State<VoucherFld> {
  final TextEditingController _controller = TextEditingController();
  String _message = "";

  Future<void> _applyVoucher() async {
    final code = _controller.text.trim();

    if (code.isEmpty) {
      setState(() {
        _message = "Please input a voucher first.";
      });
      return;
    }

    try {
      final response = await http.post(
        AppConfig.apply_voucher,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code, 'totalPrice': widget.totalPrice}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          widget.onDiscountApplied((data['discount_amount'] as num).toDouble());
          setState(() {
            _message = data['message'];
          });
        } else {
          setState(() {
            _message = data['message'];
          });
        }
      } else {
        setState(() {
          _message = "Server error occurred.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 211, 211, 211)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Have a voucher code? Enter here",
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  width: 75,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  //--------VOUCHER BUTTON
                  child: TextButton(
                    onPressed: _applyVoucher,

                    child: const Text(
                      "Apply",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _message,
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}



///------PRODUCT OVERVIEW
class PrdOvrview extends StatelessWidget {
  final List<Product> selectedProducts; 

  const PrdOvrview({
    super.key,
    required this.selectedProducts,
  });

  @override
  Widget build(BuildContext context) {
        
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (_, __) => const SizedBox(height: 32,), 
      itemCount: selectedProducts.length,
      itemBuilder: (_, index) {
        final product = selectedProducts[index];
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              //IMAGE Uri
              Image.network(
                AppConfig.fullImageUrl(product.imageUrl!), // image path from backend
                width: 90,
                height: 90,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
              const SizedBox(width: 24,),
            
              //TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //PRODUCT NAME
                    Text(
                      product.name, 
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            
                    //PRD PRICE
                    Text(
                     'P${product.price.toStringAsFixed(2)}', 
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12)),
                          
                    const SizedBox(height: 10,),
                   
                          
                    //ATTRIBUTES
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Quantity:', style: TextStyle(fontSize: 10)),
                          WidgetSpan(child: SizedBox(width: 14)),
                          TextSpan(text: product.cartQuantity.toString(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                          WidgetSpan(child: SizedBox(width: 14)),
                        ]
                      )
                    ),

                    if (product.color.isNotEmpty || product.size.isNotEmpty)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Color', style: TextStyle(fontSize: 10)),
                          WidgetSpan(child: SizedBox(width: 14)),
                          TextSpan(text: product.color, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                          WidgetSpan(child: SizedBox(width: 14)),
                          TextSpan(text: 'Size', style: TextStyle(fontSize: 10)),
                          WidgetSpan(child: SizedBox(width: 14)),
                          TextSpan(text: product.size, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                        ]
                      )
                    ),
                  ],
                ),
              )
            ],
          )
        ]
      );
      }
      );
  }
}

