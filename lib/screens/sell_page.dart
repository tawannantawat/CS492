import 'dart:io';
import 'package:cheese_sheet/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellPage extends StatefulWidget {
  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title, _university, _term, _year, _type, _price, _pdfPath;

  final List<String> _years =
      List<String>.generate(26, (i) => (2000 + i).toString());
  final List<String> _terms = ['1', '2', '3', 'อื่นๆ'];
  final List<String> _types = ['Mid Term', 'Final', 'อื่นๆ'];

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _pdfPath = result.files.single.path;
      });
    }
  }

  Future<void> _saveLecture() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('คุณต้องเข้าสู่ระบบก่อนลงขาย')),
      );
      return;
    }

    String sellerId = currentUser.uid; // ✅ ใช้ user id ของผู้ขาย

    if (_formKey.currentState!.validate() && _pdfPath != null) {
      _formKey.currentState!.save();
      try {
        final fileName = Uuid().v4() + '.pdf';

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        final response = await Supabase.instance.client.storage
            .from('lectures')
            .upload(fileName, File(_pdfPath!));

        if (response.isNotEmpty) {
          final pdfUrl = Supabase.instance.client.storage
              .from('lectures')
              .getPublicUrl(fileName);

          final insertResponse =
              await Supabase.instance.client.from('lectures').insert({
            'title': _title,
            'university': _university,
            'term': _term,
            'year': _year,
            'type': _type,
            'price': double.parse(_price ?? '0'),
            'pdfUrl': pdfUrl,
            'rating': 0.0,
            'seller_id': sellerId, // ✅ เพิ่ม seller_id
          }).select();

          if (insertResponse != null && insertResponse.isNotEmpty) {
            if (mounted) {
              Navigator.pop(context); // ✅ ปิด Dialog ถ้ายังอยู่ใน Widget
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lecture "${_title}" ลงขายเรียบร้อยแล้ว!'),
                backgroundColor: Color(0xFFF5C842),
              ),
            );

            // ✅ แทนที่หน้าปัจจุบันด้วยหน้า MainPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          } else {
            throw 'เกิดข้อผิดพลาดในการบันทึกข้อมูลใน Supabase';
          }
        } else {
          throw 'เกิดข้อผิดพลาดในการอัปโหลดไฟล์';
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // ✅ ปิด Dialog ก่อนแสดง Error
        }
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วนและเลือกไฟล์ PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell Lecture'),
        backgroundColor: Color(0xFFF5C842),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('ชื่อ Lecture', Icons.title, (value) {
                _title = value;
              }),
              _buildTextField('มหาวิทยาลัย', Icons.school, (value) {
                _university = value;
              }),
              _buildDropdownField('เทอม', Icons.calendar_today, _terms, _term,
                  (value) {
                setState(() {
                  _term = value;
                });
              }),
              _buildDropdownField('ปีการศึกษา', Icons.date_range, _years, _year,
                  (value) {
                setState(() {
                  _year = value;
                });
              }),
              _buildDropdownField(
                  'ประเภท Lecture', Icons.category, _types, _type, (value) {
                setState(() {
                  _type = value;
                });
              }),
              _buildTextField('ราคา (บาท)', Icons.attach_money, (value) {
                _price = value;
              }, keyboardType: TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickPdfFile,
                icon: Icon(Icons.upload_file),
                label: Text(_pdfPath == null
                    ? 'เลือกไฟล์ PDF'
                    : 'เลือกไฟล์: ${_pdfPath!.split('/').last}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5C842),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveLecture,
                child: Text('ลงขาย Lecture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5C842),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String) onSave,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFFF5C842)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) => value!.isEmpty ? 'กรุณาระบุ$label' : null,
        onSaved: (value) => onSave(value!),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDropdownField(String label, IconData icon, List<String> items,
      String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFFF5C842)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'กรุณาเลือก$label' : null,
      ),
    );
  }
}
