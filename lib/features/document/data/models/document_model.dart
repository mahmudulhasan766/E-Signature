import 'package:e_signature/features/document/data/models/field_model.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.name,
    required super.filePath,
    required super.userId,
    required super.fields,
    required super.isPublished,
    required super.createdAt,
    super.publishedAt,
    required super.fileType,
  });

  factory DocumentModel.fromEntity(DocumentEntity entity) {
    return DocumentModel(
      id: entity.id,
      name: entity.name,
      filePath: entity.filePath,
      userId: entity.userId,
      fields: entity.fields,
      isPublished: entity.isPublished,
      createdAt: entity.createdAt,
      publishedAt: entity.publishedAt,
      fileType: entity.fileType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'userId': userId,
      'fields': fields.map((f) => FieldModel.fromEntity(f).toJson()).toList(),
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'fileType': fileType,
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      filePath: json['filePath'] as String,
      userId: json['userId'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map((f) => FieldModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      isPublished: json['isPublished'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      fileType: json['fileType'] as String,
    );
  }

  factory DocumentModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return DocumentModel(
      id: documentId,
      name: data['name'] as String,
      filePath: data['filePath'] as String,
      userId: data['userId'] as String,
      fields: (data['fields'] as List<dynamic>?)
          ?.map((f) => FieldModel.fromJson(f as Map<String, dynamic>))
          .toList() ??
          [],
      isPublished: data['isPublished'] as bool? ?? false,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      publishedAt: data['publishedAt'] != null
          ? (data['publishedAt'] as dynamic).toDate()
          : null,
      fileType: data['fileType'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'filePath': filePath,
      'userId': userId,
      'fields': fields.map((f) => FieldModel.fromEntity(f).toJson()).toList(),
      'isPublished': isPublished,
      'createdAt': createdAt,
      'publishedAt': publishedAt,
      'fileType': fileType,
    };
  }
}