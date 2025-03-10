import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cheese_sheet/screens/payment_page.dart';

class LectureDetailsPage extends StatelessWidget {
  final Map<String, dynamic> lecture;

  LectureDetailsPage({required this.lecture});

  Future<void> _confirmPurchase(BuildContext context) async {
    bool? confirmPurchase = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการซื้อ'),
        content: Text(
            'คุณต้องการซื้อ Lecture นี้ในราคา ฿${lecture['price']} จริงหรือไม่?'),
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
    final String? lectureId = lecture['id']?.toString();

    if (lectureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถซื้อ Lecture นี้ได้: ID เป็น null')),
      );
      print('Error: ID ของ Lecture เป็น null');
      return;
    }

    try {
      // สร้างรายการสั่งซื้อ (Order) ใหม่ใน Supabase
      final response = await Supabase.instance.client
          .from('orders')
          .insert({
            'lecture_id': lectureId,
            'price': lecture['price'],
            'status': 'pending',
          })
          .select()
          .single();

      if (response != null) {
        final String orderId = response['id'].toString();
        final String phoneNumber = '0956835069'; // หมายเลข PromptPay ของคุณ
        final String paymentUrl =
            'https://promptpay.io/$phoneNumber/${lecture['price']}';

        // ไปยังหน้าแสดง QR Code สำหรับการชำระเงิน
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              orderId: orderId,
              paymentUrl: paymentUrl,
              lectureId: lectureId, // ส่ง lecture ทั้งหมดไปแทน
            ),
          ),
        );
      } else {
        print('Error: ไม่สามารถสร้างคำสั่งซื้อได้');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถสร้างคำสั่งซื้อได้')),
        );
      }
    } catch (e) {
      print('Error: ${e.toString()}');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${lecture['title']}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('University: ${lecture['university'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Year: ${lecture['year'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Term: ${lecture['term'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Type: ${lecture['type'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Price: ฿${lecture['price'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Rating: ${lecture['rating'] ?? 'N/A'} ⭐️'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmPurchase(context),
              child: Text('ซื้อ Lecture นี้'),
            ),
          ],
        ),
      ),
    );
  }
}
