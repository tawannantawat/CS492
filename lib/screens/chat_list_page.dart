import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListPage extends StatelessWidget {
  final _supabase = Supabase.instance.client;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<List<Map<String, dynamic>>> _fetchChatUsers() async {
    // ✅ แก้ SELECT ให้ระบุ FK ให้ชัดเจน
    final response = await _supabase
        .from('messages')
        .select('''
          sender_id, receiver_id, 
          sender:users!fk_sender(id, display_name), 
          receiver:users!fk_receiver(id, display_name)
        ''')
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
        .order('timestamp', ascending: false);

    if (response == null) {
      throw 'เกิดข้อผิดพลาดในการโหลดข้อมูลจาก Supabase';
    }

    // ✅ ใช้ Set ป้องกันรายชื่อซ้ำกัน
    Set<String> seenUserIds = {};
    List<Map<String, dynamic>> chatUsers = [];

    for (var chat in response) {
      String chatUserId = chat['sender_id'] == currentUserId
          ? chat['receiver_id']
          : chat['sender_id'];

      // ✅ เลือกชื่อผู้ใช้ให้ถูกต้อง
      String chatUserName;
      if (chat['sender_id'] == currentUserId) {
        chatUserName = chat['receiver']?['display_name'] ?? 'Unknown';
      } else {
        chatUserName = chat['sender']?['display_name'] ?? 'Unknown';
      }

      if (!seenUserIds.contains(chatUserId)) {
        seenUserIds.add(chatUserId);
        chatUsers.add({'id': chatUserId, 'name': chatUserName});
      }
    }

    return chatUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Color(0xFFF5C842),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchChatUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

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
                      user['name'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    user['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Tap to chat'),
                  trailing: Icon(Icons.chat, color: Colors.blueAccent),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverId: user['id'],
                          receiverName: user['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
