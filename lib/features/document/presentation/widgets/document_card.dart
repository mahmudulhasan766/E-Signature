import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:flutter/material.dart';

class DocumentCard extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onTap;

  const DocumentCard({super.key, required this.document, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: document.isPublished
              ? Colors.green[100]
              : Colors.blue[100],
          child: Icon(
            document.isPublished ? Icons.check_circle : Icons.edit,
            color: document.isPublished ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          document.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${document.fields.length} fields',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              document.isPublished ? 'Published' : 'Draft',
              style: TextStyle(
                color: document.isPublished ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
