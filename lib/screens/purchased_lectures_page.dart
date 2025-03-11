import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cheese_sheet/screens/pdf_viewer_page.dart';
import 'package:cheese_sheet/screens/chat_page.dart'; // ✅ Import หน้าแชท

class PurchasedLecturesPage extends StatefulWidget {
  @override
  _PurchasedLecturesPageState createState() => _PurchasedLecturesPageState();
}

class _PurchasedLecturesPageState extends State<PurchasedLecturesPage> {
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<List<Map<String, dynamic>>> _fetchPurchasedLectures() async {
    final response = await Supabase.instance.client
        .from('purchased_lectures')
        .select('id, title, price, rating, pdfUrl, lecture_id');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _showReviewDialog(BuildContext context, String lectureId) async {
    double rating = 0;
    TextEditingController reviewController = TextEditingController();

    final existingReview = await Supabase.instance.client
        .from('reviews')
        .select()
        .eq('lecture_id', lectureId)
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (existingReview != null) {
      rating = existingReview['rating'].toDouble();
      reviewController.text = existingReview['review'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('ให้คะแนน Lecture'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ให้คะแนน:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color:
                              index < rating ? Colors.amber : Colors.grey[400],
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: reviewController,
                    decoration:
                        InputDecoration(labelText: 'รีวิวเพิ่มเติม (ถ้ามี)'),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.from('reviews').upsert({
                        'lecture_id': lectureId,
                        'user_id': _currentUserId,
                        'rating': rating,
                        'review': reviewController.text.trim(),
                      }, onConflict: 'user_id,lecture_id');

                      await Supabase.instance.client.rpc(
                        'update_lecture_rating',
                        params: {'lecture_id': lectureId},
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('บันทึกรีวิวสำเร็จ!')),
                      );
                    } catch (e) {
                      print('Error: ${e.toString()}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
                      );
                    } finally {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: Text('บันทึกรีวิว'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ ฟังก์ชันดึง seller_id เพื่อนำไปใช้แชท
  Future<String?> _fetchSellerId(String lectureId) async {
    final response = await Supabase.instance.client
        .from('lectures')
        .select('seller_id') // ✅ ต้องเพิ่ม seller_id ในตาราง lectures
        .eq('id', lectureId)
        .maybeSingle();

    return response?['seller_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Purchased Lectures')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPurchasedLectures(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var lectures = snapshot.data!;

          return ListView.builder(
            itemCount: lectures.length,
            itemBuilder: (context, index) {
              var lecture = lectures[index];
              return ListTile(
                title: Text(lecture['title']),
                subtitle: Text(
                    'Price: ฿${lecture['price']} | Rating: ${lecture['rating'].toStringAsFixed(1)} ⭐️'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf, color: Colors.blue),
                      onPressed: () {
                        String? pdfUrl = lecture['pdfUrl']?.toString();
                        if (pdfUrl != null && pdfUrl.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PdfViewerPage(pdfPath: pdfUrl),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('ไม่พบลิงก์ PDF สำหรับ Lecture นี้')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.chat, color: Colors.green), // ✅ ปุ่มแชท
                      onPressed: () async {
                        String? sellerId =
                            await _fetchSellerId(lecture['lecture_id']);
                        if (sellerId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiverId: sellerId,
                                receiverName:
                                    'Seller', // เปลี่ยนเป็นชื่อคนขายถ้ามี
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ไม่พบข้อมูลผู้ขาย')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.rate_review, color: Colors.amber),
                      onPressed: () {
                        _showReviewDialog(context, lecture['lecture_id']);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
