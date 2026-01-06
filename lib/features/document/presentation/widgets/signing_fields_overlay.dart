
import 'package:flutter/material.dart';
import '../../domain/entities/field_entity.dart';

class SigningFieldsOverlay extends StatelessWidget {
  final List<FieldEntity> fields;
  final Map<String, String> fieldValues;
  final int currentFieldIndex;

  const SigningFieldsOverlay({
    super.key,
    required this.fields,
    required this.fieldValues,
    required this.currentFieldIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: fields.asMap().entries.map((entry) {
        final index = entry.key;
        final field = entry.value;
        final isCurrent = index == currentFieldIndex;
        final isFilled = fieldValues.containsKey(field.id);

        return Positioned(
          left: field.x,
          top: field.y,
          child: Container(
            width: field.width,
            height: field.height,
            decoration: BoxDecoration(
              color: isFilled
                  ? Colors.green.withOpacity(0.3)
                  : isCurrent
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.2),
              border: Border.all(
                color: isFilled
                    ? Colors.green
                    : isCurrent
                    ? Colors.blue
                    : Colors.orange,
                width: isCurrent ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: isFilled
                  ? const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              )
                  : isCurrent
                  ? const Icon(
                Icons.touch_app,
                color: Colors.blue,
                size: 20,
              )
                  : Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}