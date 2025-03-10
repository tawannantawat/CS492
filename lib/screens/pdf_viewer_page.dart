import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfPath;

  PdfViewerPage({required this.pdfPath});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: _loadPdfDocument(),
    );
  }

  Future<PdfDocument> _loadPdfDocument() async {
    try {
      if (widget.pdfPath.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.pdfPath));
        if (response.statusCode == 200) {
          Uint8List pdfData = response.bodyBytes;
          return PdfDocument.openData(pdfData);
        } else {
          throw Exception('ไม่สามารถโหลด PDF ได้: ${response.statusCode}');
        }
      } else {
        return PdfDocument.openAsset(widget.pdfPath);
      }
    } catch (e) {
      throw Exception('ไม่สามารถเปิดไฟล์ PDF ได้: $e');
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View PDF')),
      body: PdfViewPinch(
        controller: _pdfController,
      ),
    );
  }
}
