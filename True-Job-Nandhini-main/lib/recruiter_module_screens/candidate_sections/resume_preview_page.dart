import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:truejobs/constants/app_colors.dart';

class ResumePreviewPage extends StatelessWidget {
  final String url;
  final String title;

  const ResumePreviewPage({
    super.key,
    required this.url,
    this.title = 'Resume',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (url.isEmpty) {
      return const Center(
        child: Text(
          'No resume provided.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
      );
    }

    final isImage = url.toLowerCase().endsWith('.jpg') || 
                    url.toLowerCase().endsWith('.jpeg') || 
                    url.toLowerCase().endsWith('.png');

    if (isImage) {
      return InteractiveViewer(
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            url,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 64, color: Colors.grey);
            },
          ),
        ),
      );
    }

    final isWord = url.toLowerCase().endsWith('.doc') || 
                   url.toLowerCase().endsWith('.docx');
    
    if (isWord) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Word documents (.doc/.docx) cannot be previewed inline. Please download the file to view it.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    // Default to PDF rendering
    return SfPdfViewer.network(url);
  }
}
