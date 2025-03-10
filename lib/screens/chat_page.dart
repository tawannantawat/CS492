import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (_messageController.text.trim().isNotEmpty) {
      await _supabase.from('messages').insert({
        'sender_id': 'mockUser',
        'receiver_id': widget.receiverId,
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
    }
  }

  void _listenForMessages() {
    _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: true)
        .listen((snapshot) {
          setState(() {
            messages = snapshot
                .where((msg) =>
                    (msg['sender_id'] == 'mockUser' &&
                        msg['receiver_id'] == widget.receiverId) ||
                    (msg['sender_id'] == widget.receiverId &&
                        msg['receiver_id'] == 'mockUser'))
                .toList();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
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
                bool isMe = message['sender_id'] == 'mockUser';

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
                    child: Text(
                      message['message'],
                      style: TextStyle(color: Colors.black87),
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
