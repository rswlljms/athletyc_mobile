import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagePage extends StatefulWidget {
  final int buyerId;
  final int sellerId;

  const MessagePage({super.key, required this.buyerId, required this.sellerId});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final response = await http.post(
      AppConfig.get_messages,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'buyer_id': widget.buyerId,
        'seller_id': widget.sellerId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data['messages']);
        });
      } else {
        print('Failed to load messages');
      }
    }
  }

  Future<void> sendMessage() async {
  final messageText = _messageController.text.trim();
  if (messageText.isEmpty) return;

  try {
    final response = await http.post(
      
      AppConfig.send_message,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'buyer_id': widget.buyerId.toString(),
        'seller_id': widget.sellerId.toString(),
        'message': messageText,
      },
    );

    if (response.statusCode == 200) {
      _messageController.clear();
      await fetchMessages();  // await this if fetchMessages is async
    } else {
      print('Failed to send message. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}


  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isBuyer = message['role'] == 'buyer';
    final createdAt = message['created_at'] ?? ''; // Make sure it's a formatted string

    return Column(
      crossAxisAlignment:
          isBuyer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            createdAt,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
        Align(
          alignment: isBuyer ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: isBuyer ? Colors.blue[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message['message'],
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                  color: Colors.blue,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
