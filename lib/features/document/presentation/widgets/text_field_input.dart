import 'package:flutter/material.dart';
import '../../domain/entities/field_entity.dart';

class TextFieldInput extends StatefulWidget {
  final FieldEntity field;
  final String? initialValue;
  final Function(String) onCompleted;

  const TextFieldInput({
    super.key,
    required this.field,
    this.initialValue,
    required this.onCompleted,
  });

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Enter text here',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter text before continuing'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            widget.onCompleted(text);
          },
          icon: const Icon(Icons.check),
          label: const Text('Save Text'),
        ),
      ],
    );
  }
}
