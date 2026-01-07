import 'package:flutter/material.dart';
import '../../domain/entities/field_entity.dart';

class CheckboxFieldInput extends StatefulWidget {
  final FieldEntity field;
  final bool initialValue;
  final Function(bool) onCompleted;

  const CheckboxFieldInput({
    super.key,
    required this.field,
    required this.initialValue,
    required this.onCompleted,
  });

  @override
  State<CheckboxFieldInput> createState() => _CheckboxFieldInputState();
}

class _CheckboxFieldInputState extends State<CheckboxFieldInput> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              Checkbox(
                value: _isChecked,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
                activeColor: Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isChecked ? 'Checked' : 'Not checked',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            widget.onCompleted(_isChecked);
          },
          icon: const Icon(Icons.check),
          label: const Text('Save Selection'),
        ),
      ],
    );
  }
}
