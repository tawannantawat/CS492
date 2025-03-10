import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LectureListTile extends StatelessWidget {
  final Map<String, dynamic> lecture;

  LectureListTile({required this.lecture});

  // ฟังก์ชันแสดง Pop-up ยืนยันการซื้อ
  Future<void> _confirmPurchase(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการซื้อ'),
          content: Text('คุณต้องการซื้อ "${lecture['title']}" ใช่หรือไม่?'),
          actions: [
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('ยืนยัน'),
              onPressed: () async {
                await _purchaseLecture(lecture['title']);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'คุณได้ซื้อ ${lecture['title']} เรียบร้อยแล้ว!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันบันทึก Lecture ที่ซื้อแล้วใน SharedPreferences
  Future<void> _purchaseLecture(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> purchasedLectures =
        prefs.getStringList('purchasedLectures') ?? [];
    if (!purchasedLectures.contains(title)) {
      purchasedLectures.add(title);
      await prefs.setStringList('purchasedLectures', purchasedLectures);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(lecture['title']),
        subtitle: Text(
          'University: ${lecture['university']} | Term: ${lecture['term']} | Year: ${lecture['year']} | Rating: ${lecture['rating']} ⭐️',
        ),
        trailing: ElevatedButton(
          onPressed: () => _confirmPurchase(context),
          child: Text('Buy Now'),
        ),
      ),
    );
  }
}
