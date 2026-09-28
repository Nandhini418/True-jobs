import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../constants/app_colors.dart';

class ResumePreviewPage extends StatelessWidget {
  final File? file;
  final String? url;
  final String title;

  const ResumePreviewPage({
    super.key,
    this.file,
    this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final String extension = title.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(extension);
    final isPdf = ['pdf'].contains(extension);
    final bool isNetwork = url != null && url!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'View Resume',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: isImage
              ? InteractiveViewer(
                  maxScale: 4.0,
                  child: isNetwork
                      ? Image.network(
                          url!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image, size: 80)),
                        )
                      : Image.file(
                          file!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                )
              : isPdf
                  ? (isNetwork
                      ? SfPdfViewer.network(
                          url!,
                          canShowScrollHead: true,
                          canShowScrollStatus: true,
                        )
                      : SfPdfViewer.file(
                          file!,
                          canShowScrollHead: true,
                          canShowScrollStatus: true,
                        ))
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description,
                            color: AppColors.primary,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Word documents (.doc/.docx) cannot be previewed inline. Please upload a PDF or Image to see an in-app preview.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
