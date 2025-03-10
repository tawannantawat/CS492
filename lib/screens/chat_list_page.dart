import 'package:flutter/material.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  final List<Map<String, String>> mockUsers = [
    {'id': '1', 'name': 'Admin'},
    {'id': '2', 'name': 'Support'},
    {'id': '3', 'name': 'John Doe'},
    {'id': '4', 'name': 'Jane Smith'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Color(0xFFF5C842),
      ),
      body: ListView.builder(
        itemCount: mockUsers.length,
        itemBuilder: (context, index) {
          final user = mockUsers[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFF5C842),
                child: Text(
                  user['name']![0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                user['name']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Tap to chat'),
              trailing: Icon(Icons.chat, color: Colors.blueAccent),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverId: user['id']!,
                      receiverName: user['name']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
