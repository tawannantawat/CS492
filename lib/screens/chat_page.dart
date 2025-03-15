import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ✅ ใช้ intl เพื่อ format timestamp

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  ChatPage({required this.receiverId, required this.receiverName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _listenForMessages();
  }

  Future<void> _sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('Error: User not logged in');
      return;
    }

    String senderId = currentUser.uid;

    if (_messageController.text.trim().isNotEmpty) {
      await _supabase.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': widget.receiverId,
        'message': _messageController.text.trim(),
        'timestamp':
            DateTime.now().toUtc().toIso8601String(), // ✅ ใช้เวลาปัจจุบัน
      });

      _messageController.clear();
    }
  }

  void _listenForMessages() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('Error: User not logged in');
      return;
    }

    String senderId = currentUser.uid;

    _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: true)
        .listen((snapshot) {
          setState(() {
            messages = snapshot
                .where((msg) =>
                    (msg['sender_id'] == senderId &&
                        msg['receiver_id'] == widget.receiverId) ||
                    (msg['sender_id'] == widget.receiverId &&
                        msg['receiver_id'] == senderId))
                .toList();
          });

          print('📩 Messages: $messages');
        });
  }

  String _formatTimestamp(String timestamp) {
    try {
      DateTime dateTime =
          DateTime.parse(timestamp).toLocal(); // ✅ แปลงเป็นเวลาท้องถิ่น
      return DateFormat('HH:mm').format(dateTime); // ✅ แสดงเป็น "14:30"
    } catch (e) {
      return ''; // ❌ ถ้า timestamp ผิดพลาด ให้คืนค่าว่าง
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    String senderId = currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverName}'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isMe = message['sender_id'] == senderId;
                String formattedTime = _formatTimestamp(message['timestamp']);

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.orange[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'],
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ), // ✅ แสดงเวลาข้อความ
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
