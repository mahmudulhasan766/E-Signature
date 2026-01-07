import 'dart:io';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentViewer extends StatelessWidget {
  final DocumentEntity document;
  final PdfViewerController pdfController;
  final TransformationController transformationController;
  final Function(Offset) onTap;

  const DocumentViewer({
    super.key,
    required this.document,
    required this.pdfController,
    required this.transformationController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        onTap(localPosition);
      },
      child: Container(
        color: Colors.grey[300],
        child: document.filePath.startsWith('http')
            ? SfPdfViewer.network(
          document.filePath,
          controller: pdfController,
          canShowScrollHead: false,
          enableDoubleTapZooming: true,
        )
            : SfPdfViewer.file(
          File(document.filePath),
          controller: pdfController,
          canShowScrollHead: false,
          enableDoubleTapZooming: true,
        ),
      ),
    );
  }
}