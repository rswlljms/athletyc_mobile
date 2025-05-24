import 'dart:convert';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ToRate extends StatefulWidget {


   const ToRate({
    super.key,
  });

  @override
  ToRateState createState() => ToRateState();
}

class ToRateState extends State<ToRate> {
  List<dynamic> orders = [];
    Map<int, GlobalKey<FormState>> formKeys = {};
    Map<int, TextEditingController> feedbackControllers = {};
    Map<int, TextEditingController> reportControllers = {};



  @override
  void initState() {
    super.initState();
    fetchToRate();
  }

  //GET EMAIL
  Future<void> fetchToRate() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    //LOAD ORDERS
    final response = await http.get(AppConfig.show_to_rate(email));

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
        for (int i = 0; i < orders.length; i++) {
          formKeys[i] = GlobalKey<FormState>();
          feedbackControllers[i] = TextEditingController();
          reportControllers[i] = TextEditingController();
        }
      });

    } else {
      print('Failed to load orders');
    }
  }


  
  //SUBMIT FEEDBACK
   Future<void> submitFeedback(int index, Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final formKey = formKeys[index];
    final feedback = feedbackControllers[index]!.text;
    final report = reportControllers[index]!.text;

   if (formKey != null && formKey.currentState!.validate()) {
    final response = await http.post(
      AppConfig.order_feedback,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_email': email,
        'order_id': item['orderID'],
        'productID': item['productID'],
        'feedback': feedback,
        'sellerID': item['sellerID'],
        'report_reason': report,
      }),
    );
    
    print('ITEM BEING SUBMITTED: $item');

    if (response.statusCode == 200) {
      feedbackControllers[index]?.clear();
      reportControllers[index]?.clear();


       Get.snackbar(
        "Success!", 
        "Feedback submitted successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      setState(() {
        orders.remove(item);
      });
    } else {
      Get.snackbar(
        "Failed!", 
        "Submission failed.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Rate'),
      ),
      body: orders.isEmpty
        ? Center(
            child: Text(
              'No orders to rate at the moment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
        : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final item = orders[index];
          final statusHistory = item['status_history'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${item['orderID']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                 Text('Date of order: ${item['date']}', style: TextStyle(fontSize: 12)),
                SizedBox(height: 14),
                Row(
                  children: [
                    //Uri
                    Image.network(
                      AppConfig.fullImageUrl(item['image_paths']),
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.image),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         
                          Text(item['prName'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Quantity: ${item['quantity']}', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 4),
                          Text('Price: ${item['prPrice']}', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 4),
                          Text('P${item['price']}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 63, 91, 216))),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                // STATUS HISTORY 
                Text('Status History:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(statusHistory.length, (i) {
                    final statusItem = statusHistory[i];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 14, color: Colors.grey),
                          SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${statusItem['status'].toString().toUpperCase()}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${statusItem['updated_at']}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                SizedBox(height: 14),
                Form(
                  key: formKeys[index],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Feedback:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      TextFormField(
                        controller: feedbackControllers[index],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Feedback is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),
                      Text('Reason for Reporting:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      TextFormField(
                        controller: reportControllers[index],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),

                      //BUTTON
                      SizedBox(width: double.infinity, height:45, child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, foregroundColor: Colors.white,
                          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))), 
                      onPressed: () => submitFeedback(index, item),
                    child: const Text("SUBMIT FEEDBACK", style: TextStyle(color: Colors.white, fontSize: 16))))
                    ],
                ))
                
              ],
            ),
          );
        },
      ),
    );
  }
}
