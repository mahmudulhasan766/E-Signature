import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:equatable/equatable.dart';

class DocumentEntity extends Equatable {
  final String id;
  final String name;
  final String filePath;
  final String userId;
  final List<FieldEntity> fields;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String fileType;

  const DocumentEntity({
    required this.id,
    required this.name,
    required this.filePath,
    required this.userId,
    required this.fields,
    required this.isPublished,
    required this.createdAt,
    this.publishedAt,
    required this.fileType,
  });

  DocumentEntity copyWith({
    String? id,
    String? name,
    String? filePath,
    String? userId,
    List<FieldEntity>? fields,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? fileType,
  }) {
    return DocumentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      userId: userId ?? this.userId,
      fields: fields ?? this.fields,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      fileType: fileType ?? this.fileType,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    filePath,
    userId,
    fields,
    isPublished,
    createdAt,
    publishedAt,
    fileType,
  ];
}