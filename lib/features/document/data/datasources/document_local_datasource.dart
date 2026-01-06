import 'dart:io';
import 'package:e_signature/core/errors/exceptions.dart';
import 'package:path_provider/path_provider.dart';

abstract class DocumentLocalDataSource {
  Future<String> saveFieldsToFile(String jsonData, String documentId);
  Future<String> readFieldsFromFile(String filePath);
  Future<String> savePdfToLocal(List<int> pdfBytes, String fileName);
}

class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
  @override
  Future<String> saveFieldsToFile(String jsonData, String documentId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/fields_$documentId.json');
      await file.writeAsString(jsonData);
      return file.path;
    } catch (e) {
      throw CacheException('Failed to save fields to file: $e');
    }
  }

  @override
  Future<String> readFieldsFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw CacheException('File not found');
      }
      return await file.readAsString();
    } catch (e) {
      throw CacheException('Failed to read fields from file: $e');
    }
  }

  @override
  Future<String> savePdfToLocal(List<int> pdfBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      throw CacheException('Failed to save PDF: $e');
    }
  }
}