// pdf_viewer_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerPage({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  static const Color primaryColor = Color(0xFF5D9493);
  static const Color secondaryColor = Color(0xFF8CA1A4);
  static const Color darkColor = Color(0xFF21464E);
  static const Color lightColor = Color(0xFFF8F9F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [secondaryColor, primaryColor],
            ),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Use the network PDF viewer
      // body: SfPdfViewer.network(
      //   url,
      // ),
    );
  }
}