import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cheese_sheet/screens/login_page.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // ทำการออกจากระบบทุกครั้งเมื่อเริ่มแอป
  await FirebaseAuth.instance.signOut();
  await ScreenProtector.preventScreenshotOn();
  await Supabase.initialize(
    url:
        'https://ikriwhicgguhslwcgvvt.supabase.co', // เปลี่ยนเป็น URL ของ Supabase
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlrcml3aGljZ2d1aHNsd2NndnZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExODgzMjUsImV4cCI6MjA1Njc2NDMyNX0.UquaByoiYwnOlTrHrgNLzyUpF0PdJZN1ogtJffAdgwY', // เปลี่ยนเป็น API Key ของ Supabase
  );
  runApp(CheeseSheetApp());
}

class CheeseSheetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cheese Sheet',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: LoginPage(),
    );
  }
}
