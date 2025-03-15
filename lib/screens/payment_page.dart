import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final String paymentUrl;
  final String lectureId;

  PaymentPage({
    required this.orderId,
    required this.paymentUrl,
    required this.lectureId,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String status = 'pending';

  @override
  void initState() {
    super.initState();
    _listenToPaymentStatus();
  }

  void _listenToPaymentStatus() {
    final orderStream = Supabase.instance.client
        .from('orders')
        .stream(primaryKey: ['id']).eq('id', widget.orderId);

    orderStream.listen((data) async {
      if (data.isNotEmpty && data.first['status'] == 'paid') {
        setState(() {
          status = 'paid';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ชำระเงินสำเร็จ! สามารถอ่านชีทได้แล้ว')),
        );

        await _addToPurchasedLectures();

        // ✅ ค้างหน้าจอไว้ 2 วินาทีก่อนกลับไปหน้าแรก
        await Future.delayed(Duration(seconds: 2));

        // กลับไปหน้าแรก
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  Future<void> _addToPurchasedLectures() async {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ไม่พบข้อมูลผู้ใช้')),
      );
      return;
    }
    try {
      // ดึงข้อมูล Lecture จากตาราง lectures โดยใช้ lecture_id
      final response = await Supabase.instance.client
          .from('lectures')
          .select('*')
          .eq('id', widget.lectureId)
          .single();

      if (response != null) {
        await Supabase.instance.client.from('purchased_lectures').insert({
          'lecture_id': widget.lectureId,
          'order_id': widget.orderId,
          'user_id': currentUserId,
          'title': response['title'],
          'university': response['university'],
          'term': response['term'],
          'year': response['year'],
          'type': response['type'],
          'price': response['price'],
          'rating': response['rating'],
          'pdfUrl': response['pdfUrl'],
        });

        print('Lecture ถูกเพิ่มลงใน Purchased Lectures แล้ว');
      } else {
        print('Error: ไม่พบข้อมูล Lecture ใน Supabase');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่พบข้อมูล Lecture ในระบบ')),
        );
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    }
  }

  Future<void> _simulatePayment() async {
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .update({'status': 'paid'}).eq('id', widget.orderId);

      if (response != null) {
        print('สถานะคำสั่งซื้อถูกเปลี่ยนเป็น "paid" เรียบร้อยแล้ว');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('สถานะการชำระเงินเปลี่ยนเป็น Paid')),
        );
      } else {
        print('Error: ไม่สามารถเปลี่ยนสถานะการชำระเงินได้');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ชำระเงิน')),
      body: Center(
        child: status == 'pending'
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    widget.paymentUrl,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Text('กรุณาสแกน QR Code เพื่อชำระเงิน'),
                  SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: _simulatePayment,
                  //   child: Text('จำลองการชำระเงิน'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor:
                  //         Colors.orange, // ✅ ใช้ backgroundColor แทน primary
                  //   ),
                  // ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 100),
                  SizedBox(height: 20),
                  Text('ชำระเงินเรียบร้อยแล้ว!'),
                ],
              ),
      ),
    );
  }
}
