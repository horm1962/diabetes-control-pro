import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PdfViewerScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          // The PdfPreview widget already includes these actions, 
          // but we can add more if needed here.
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        actions: const [], // Standard actions like print and share are enabled by default
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        maxPageWidth: 700,
        pdfFileName: fileName,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }
}
