import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _displayNameController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentDisplayName();
  }

  Future<void> _fetchCurrentDisplayName() async {
    final response = await _supabase
        .from('users')
        .select('display_name')
        .eq('id', currentUserId)
        .maybeSingle();

    if (response != null && response['display_name'] != null) {
      _displayNameController.text = response['display_name'];
    }
  }

  Future<void> _updateDisplayName() async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Display Name cannot be empty')),
      );
      return;
    }

    try {
      await _supabase.from('users').update({
        'display_name': _displayNameController.text.trim(),
      }).eq('id', currentUserId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Display Name Updated Successfully!')),
      );

      Navigator.pop(context); // กลับไปยังหน้า Main
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update Display Name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xFFF5C842),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Display Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'New Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateDisplayName,
              child: Text('Update Name'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF5C842),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            Divider(height: 30, thickness: 1),
            Text(
              'Other Settings (Coming Soon)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.grey),
              title: Text('Change Password'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.color_lens, color: Colors.grey),
              title: Text('Change Theme'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
