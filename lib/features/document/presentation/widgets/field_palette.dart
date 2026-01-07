import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:flutter/material.dart';

class FieldPalette extends StatelessWidget {
  final FieldType? selectedType;
  final Function(FieldType) onFieldTypeSelected;

  const FieldPalette({
    super.key,
    required this.selectedType,
    required this.onFieldTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.touch_app, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select a field type and tap on the document to place it',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FieldTypeButton(
                  type: FieldType.signature,
                  icon: Icons.draw,
                  label: 'Signature',
                  isSelected: selectedType == FieldType.signature,
                  onTap: () => onFieldTypeSelected(FieldType.signature),
                ),
                const SizedBox(width: 8),
                FieldTypeButton(
                  type: FieldType.textbox,
                  icon: Icons.text_fields,
                  label: 'Text',
                  isSelected: selectedType == FieldType.textbox,
                  onTap: () => onFieldTypeSelected(FieldType.textbox),
                ),
                const SizedBox(width: 8),
                FieldTypeButton(
                  type: FieldType.checkbox,
                  icon: Icons.check_box,
                  label: 'Checkbox',
                  isSelected: selectedType == FieldType.checkbox,
                  onTap: () => onFieldTypeSelected(FieldType.checkbox),
                ),
                const SizedBox(width: 8),
                FieldTypeButton(
                  type: FieldType.date,
                  icon: Icons.calendar_today,
                  label: 'Date',
                  isSelected: selectedType == FieldType.date,
                  onTap: () => onFieldTypeSelected(FieldType.date),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FieldTypeButton extends StatelessWidget {
  final FieldType type;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FieldTypeButton({
    super.key,
    required this.type,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}