
import 'package:equatable/equatable.dart';

enum FieldType {
  signature,
  textbox,
  checkbox,
  date,
}

class FieldEntity extends Equatable {
  final String id;
  final FieldType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final String? value;
  final int pageNumber;

  const FieldEntity({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.value,
    this.pageNumber = 0,
  });

  FieldEntity copyWith({
    String? id,
    FieldType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    String? value,
    int? pageNumber,
  }) {
    return FieldEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      value: value ?? this.value,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  @override
  List<Object?> get props => [id, type, x, y, width, height, value, pageNumber];
}








// ==================== REPOSITORIES ====================





// ==================== USE CASES ====================







