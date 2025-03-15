import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cheese_sheet/screens/payment_page.dart';

class LectureDetailsPage extends StatefulWidget {
  final Map<String, dynamic> lecture;

  LectureDetailsPage({required this.lecture});

  @override
  _LectureDetailsPageState createState() => _LectureDetailsPageState();
}

class _LectureDetailsPageState extends State<LectureDetailsPage> {
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final response = await Supabase.instance.client
        .from('reviews')
        .select('user_id, rating, review')
        .eq('lecture_id', widget.lecture['id']);

    setState(() {
      reviews = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _confirmPurchase(BuildContext context) async {
    bool? confirmPurchase = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการซื้อ'),
        content: Text(
            'คุณต้องการซื้อ Lecture นี้ในราคา ฿${widget.lecture['price']} จริงหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('ซื้อเลย'),
          ),
        ],
      ),
    );

    if (confirmPurchase == true) {
      await _initiatePayment(context);
    }
  }

  Future<void> _initiatePayment(BuildContext context) async {
    final String? lectureId = widget.lecture['id']?.toString();
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (lectureId == null || currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถซื้อ Lecture นี้ได้: ID เป็น null')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('orders')
          .insert({
            'lecture_id': lectureId,
            'price': widget.lecture['price'],
            'status': 'pending',
            'user_id': currentUserId, // ✅ เพิ่ม user_id ของผู้ซื้อ
          })
          .select()
          .single();

      if (response != null) {
        final String orderId = response['id'].toString();
        final String phoneNumber = '0956835069';
        final String paymentUrl =
            'https://promptpay.io/$phoneNumber/${widget.lecture['price']}';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              orderId: orderId,
              paymentUrl: paymentUrl,
              lectureId: lectureId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถสร้างคำสั่งซื้อได้')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lecture Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${widget.lecture['title']}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('University: ${widget.lecture['university'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Year: ${widget.lecture['year'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Term: ${widget.lecture['term'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Type: ${widget.lecture['type'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Price: ฿${widget.lecture['price'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Rating: ${widget.lecture['rating'] ?? 'N/A'} ⭐️'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _confirmPurchase(context),
                child: Text('ซื้อ Lecture นี้'),
              ),
              SizedBox(height: 30),
              Divider(),
              Text('📢 รีวิวจากผู้ใช้',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              reviews.isEmpty
                  ? Text('ยังไม่มีรีวิวสำหรับ Lecture นี้')
                  : Column(
                      children: reviews.map((review) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Row(
                              children: [
                                Text('⭐ ${review['rating'].toString()}'),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    review['review'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text('ผู้ใช้: ${review['user_id']}'),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
