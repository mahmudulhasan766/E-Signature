
import 'dart:convert';

class JsonValidator {
  static bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool hasRequiredFields(String jsonString, List<String> requiredFields) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return requiredFields.every((field) => decoded.containsKey(field));
    } catch (e) {
      return false;
    }
  }

  static String? validateFieldsJson(String jsonString) {
    if (!isValidJson(jsonString)) {
      return 'Invalid JSON format';
    }

    if (!hasRequiredFields(jsonString, ['fields'])) {
      return 'Missing required "fields" array';
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final List<dynamic> fields = decoded['fields'];

      for (final field in fields) {
        if (field is! Map<String, dynamic>) {
          return 'Invalid field format';
        }

        final requiredFieldKeys = ['id', 'type', 'x', 'y', 'width', 'height'];
        for (final key in requiredFieldKeys) {
          if (!field.containsKey(key)) {
            return 'Missing required field property: $key';
          }
        }
      }

      return null; // Valid
    } catch (e) {
      return 'Error validating JSON: $e';
    }
  }
}
