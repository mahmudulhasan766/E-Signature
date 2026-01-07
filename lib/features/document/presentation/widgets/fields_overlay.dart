import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/presentation/widgets/draggable_field.dart';
import 'package:flutter/material.dart';

class FieldsOverlay extends StatelessWidget {
  final List<FieldEntity> fields;
  final Function(FieldEntity, Offset) onFieldMoved;
  final Function(FieldEntity) onFieldDeleted;

  const FieldsOverlay({
    super.key,
    required this.fields,
    required this.onFieldMoved,
    required this.onFieldDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: fields.map((field) {
        return DraggableFieldWidget(
          field: field,
          onMoved: (position) => onFieldMoved(field, position),
          onDeleted: () => onFieldDeleted(field),
        );
      }).toList(),
    );
  }
}