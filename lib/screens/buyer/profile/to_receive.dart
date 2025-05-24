import 'dart:convert';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ToReceive extends StatefulWidget {
  @override
  ToReceiveState createState() => ToReceiveState();
}

class ToReceiveState extends State<ToReceive> {
  List<dynamic> orders = [];
  bool isButtonEnabled = false; // Initially disabled

  @override
  void initState() {
    super.initState();
    fetchToReceive();
  }

  
  


  Future<void> fetchToReceive() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    final response = await http.get(AppConfig.show_to_receive(email));

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      print('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Receive'),
      ),
      body: orders.isEmpty
        ? Center(
            child: Text(
              'No orders to receive at the moment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
        : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final item = orders[index];
          final statusHistory = item['status_history'] ?? [];

        //  final isDelivered = statusHistory.isNotEmpty &&
        //             statusHistory.first['status'].toString().toLowerCase() == 'order delivered';
        final isDelivered = true; // Always enable the button


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
                    Image.network(
                      'http://192.168.94.39:5000/${item['image_paths']}',
                      width: 140,
                      height: 140,
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
                          // Text('Price: ${item['prPrice']}', style: TextStyle(fontSize: 12)),
                          // SizedBox(height: 4),
                          Text('P${item['price']}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 63, 91, 216))),
                          SizedBox(height: 12),

                          //// BUTTON
                          // Determine if the latest status is "Order Delivered"
                          

                          // BUTTON
                          SizedBox(
                            width: 150,
                            height: 45,
                            child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: isDelivered ? Colors.black : Colors.grey,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  ),
  onPressed: isDelivered
      ? () async {
          final response = await http.post(
            AppConfig.confirmOrder,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'orderID': item['orderID']}),
          );

          if (response.statusCode == 200) {
            Get.snackbar(
              "Success!",
              "Order received",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            setState(() {
              orders.remove(item);
            });
          } else {
            Get.snackbar(
              "Error",
              "Failed to update order",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      : null,
  child: const Text(
    'Confirm Order Received',
    style: TextStyle(color: Colors.white, fontSize: 12),
    textAlign: TextAlign.center,
  ),
),

                          ),

                        ],
                      ),
                    ),

                  ],
                ),

                SizedBox(height: 14),
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
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
