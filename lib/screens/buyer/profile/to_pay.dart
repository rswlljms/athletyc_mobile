import 'dart:convert';
import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ToPay extends StatefulWidget {
  @override
  ToPayState createState() => ToPayState();
}

class ToPayState extends State<ToPay> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    final response = await http.get(AppConfig.show_to_pay(email));

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
        title: Text('To Pay'),
      ),
      body: orders.isEmpty
        ? Center(
            child: Text(
              'No orders to pay at the moment',
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

                    Text('Order Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(height: 14),

                    Row(
                      children: [
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
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
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
          )
    );
  }
}
