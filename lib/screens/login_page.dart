import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ เพิ่ม Supabase
import 'package:cheese_sheet/screens/main_page.dart';
import 'package:cheese_sheet/screens/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ ฟังก์ชันเพิ่มข้อมูลผู้ใช้ใน Supabase
  Future<void> _syncUserToDatabase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // 🛑 ถ้าไม่มีผู้ใช้ล็อกอิน ไม่ต้องทำอะไร

    final supabase = Supabase.instance.client;

    // ✅ ตรวจสอบว่ามี user นี้อยู่ใน Supabase แล้วหรือยัง
    final response = await supabase
        .from('users')
        .select('id')
        .eq('id', user.uid)
        .maybeSingle();

    if (response == null) {
      // 🔹 ถ้ายังไม่มี ให้เพิ่มข้อมูลผู้ใช้ลงไป
      await supabase.from('users').insert({
        'id': user.uid,
        'email': user.email,
        'display_name': user.displayName ?? 'User ${user.uid.substring(0, 6)}',
        'created_at': DateTime.now().toIso8601String(),
      });

      print("✅ เพิ่มผู้ใช้ใหม่ใน Supabase: ${user.email}");
    } else {
      print("🔄 ผู้ใช้มีอยู่แล้วใน Supabase: ${user.email}");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);

        await _syncUserToDatabase(); // ✅ เพิ่มผู้ใช้ใน Supabase

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
    }
  }

  Future<void> _signInWithEmail() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _syncUserToDatabase(); // ✅ เพิ่มผู้ใช้ใน Supabase

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      print("❌ Email Sign-In Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
                SizedBox(height: 20),
                Text('Cheese Sheet',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange)),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signInWithEmail,
                  child: Text('Login with Email'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SignUpPage()), // ✅ เปลี่ยนไปหน้าสมัครสมาชิก
                    );
                  },
                  child: Text('Sign Up'),
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _signInWithGoogle,
                  child: Text('Sign in with Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
