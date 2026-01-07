import 'package:e_signature/core/constants/app_constants.dart';
import 'package:e_signature/core/errors/exceptions.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileHelper {
  static Future<File?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }

      return null;
    } catch (e) {
      throw FileException('Failed to pick document: $e');
    }
  }

  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  static bool isValidFileType(String filePath) {
    final extension = getFileExtension(filePath);
    return AppConstants.supportedFileTypes.contains(extension);
  }

  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  static bool isFileSizeValid(int sizeInBytes) {
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= AppConstants.maxFileSizeInMB;
  }
}
