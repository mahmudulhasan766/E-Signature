import 'package:flutter/material.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/field_entity.dart';
import 'signature_field_input.dart';
import 'text_field_input.dart';
import 'checkbox_field_input.dart';
import 'date_field_input.dart';

class SigningFieldInput extends StatelessWidget {
  final DocumentEntity document;
  final Map<String, String> fieldValues;
  final int currentFieldIndex;
  final Function(String, String) onFieldCompleted;
  final Function(int) onNavigateField;

  const SigningFieldInput({
    super.key,
    required this.document,
    required this.fieldValues,
    required this.currentFieldIndex,
    required this.onFieldCompleted,
    required this.onNavigateField,
  });

  @override
  Widget build(BuildContext context) {
    if (document.fields.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentField = document.fields[currentFieldIndex];
    final isFilled = fieldValues.containsKey(currentField.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Field Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentFieldIndex > 0
                    ? () => onNavigateField(currentFieldIndex - 1)
                    : null,
              ),
              Text(
                'Field ${currentFieldIndex + 1} of ${document.fields.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentFieldIndex < document.fields.length - 1
                    ? () => onNavigateField(currentFieldIndex + 1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Field Type Label
          Row(
            children: [
              Icon(
                _getFieldIcon(currentField.type),
                color: _getFieldColor(currentField.type),
              ),
              const SizedBox(width: 8),
              Text(
                _getFieldLabel(currentField.type),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getFieldColor(currentField.type),
                ),
              ),
              if (isFilled) ...[
                const Spacer(),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Field Input Widget
          _buildFieldInput(context, currentField, isFilled),
        ],
      ),
    );
  }

  Widget _buildFieldInput(BuildContext context, FieldEntity field, bool isFilled) {
    switch (field.type) {
      case FieldType.signature:
        return SignatureFieldInput(
          field: field,
          initialValue: fieldValues[field.id],
          onCompleted: (value) => onFieldCompleted(field.id, value),
        );
      case FieldType.textbox:
        return TextFieldInput(
          field: field,
          initialValue: fieldValues[field.id],
          onCompleted: (value) => onFieldCompleted(field.id, value),
        );
      case FieldType.checkbox:
        return CheckboxFieldInput(
          field: field,
          initialValue: fieldValues[field.id] == 'true',
          onCompleted: (value) => onFieldCompleted(field.id, value.toString()),
        );
      case FieldType.date:
        return DateFieldInput(
          field: field,
          initialValue: fieldValues[field.id],
          onCompleted: (value) => onFieldCompleted(field.id, value),
        );
    }
  }

  IconData _getFieldIcon(FieldType type) {
    switch (type) {
      case FieldType.signature:
        return Icons.draw;
      case FieldType.textbox:
        return Icons.text_fields;
      case FieldType.checkbox:
        return Icons.check_box;
      case FieldType.date:
        return Icons.calendar_today;
    }
  }

  Color _getFieldColor(FieldType type) {
    switch (type) {
      case FieldType.signature:
        return Colors.blue;
      case FieldType.textbox:
        return Colors.green;
      case FieldType.checkbox:
        return Colors.orange;
      case FieldType.date:
        return Colors.purple;
    }
  }

  String _getFieldLabel(FieldType type) {
    switch (type) {
      case FieldType.signature:
        return 'Signature Required';
      case FieldType.textbox:
        return 'Text Input Required';
      case FieldType.checkbox:
        return 'Checkbox';
      case FieldType.date:
        return 'Date Selection';
    }
  }
}