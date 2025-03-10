import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cheese_sheet/screens/pdf_viewer_page.dart';

class PurchasedLecturesPage extends StatefulWidget {
  @override
  _PurchasedLecturesPageState createState() => _PurchasedLecturesPageState();
}

class _PurchasedLecturesPageState extends State<PurchasedLecturesPage> {
  Future<List<Map<String, dynamic>>> _fetchPurchasedLectures() async {
    final response = await Supabase.instance.client
        .from('purchased_lectures') // ✅ ดึงข้อมูลจาก purchased_lectures โดยตรง
        .select('id, title, price, rating, pdfUrl, lecture_id');

    if (response == null) {
      throw 'เกิดข้อผิดพลาดในการโหลดข้อมูลจาก Supabase';
    }

    print('Purchased Lectures จาก Supabase: $response'); // ✅ ตรวจสอบข้อมูล
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _deleteLecture(String lectureId) async {
    final response = await Supabase.instance.client
        .from('purchased_lectures')
        .delete()
        .eq('id', lectureId); // ✅ ลบโดยใช้ 'id' จากตาราง purchased_lectures

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถลบ Lecture ได้')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบ Lecture ใน My Purchased เรียบร้อยแล้ว!')),
      );
      setState(() {}); // Refresh the page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Purchased Lectures')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPurchasedLectures(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child:
                    Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}'));
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
                    'Price: ฿${lecture['price']} | Rating: ${lecture['rating']} ⭐️'),
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
                              builder: (context) => PdfViewerPage(
                                  pdfPath: pdfUrl), // ✅ แก้ชื่อให้ตรงกัน
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
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('ยืนยันการลบ'),
                            content: Text('ต้องการลบ Lecture นี้จริงหรือไม่?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('ยกเลิก'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('ลบ'),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          await _deleteLecture(lecture['id'].toString());
                        }
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
