
import 'dart:convert';

import 'package:e_signature/features/document/domain/entities/field_entity.dart';

class FieldModel extends FieldEntity {
  const FieldModel({
    required super.id,
    required super.type,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    super.value,
    super.pageNumber,
  });

  factory FieldModel.fromEntity(FieldEntity entity) {
    return FieldModel(
      id: entity.id,
      type: entity.type,
      x: entity.x,
      y: entity.y,
      width: entity.width,
      height: entity.height,
      value: entity.value,
      pageNumber: entity.pageNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'value': value,
      'pageNumber': pageNumber,
    };
  }

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] as String,
      type: FieldType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => FieldType.textbox,
      ),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      value: json['value'] as String?,
      pageNumber: json['pageNumber'] as int? ?? 0,
    );
  }

  static String fieldsToJsonString(List<FieldEntity> fields) {
    final fieldsJson = fields.map((f) => FieldModel.fromEntity(f).toJson()).toList();
    return jsonEncode({'fields': fieldsJson});
  }

  static List<FieldModel> fieldsFromJsonString(String jsonString) {
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    final List<dynamic> fieldsList = decoded['fields'] as List<dynamic>;
    return fieldsList.map((json) => FieldModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}