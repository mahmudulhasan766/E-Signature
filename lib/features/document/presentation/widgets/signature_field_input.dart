import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:convert';
import '../../domain/entities/field_entity.dart';

class SignatureFieldInput extends StatefulWidget {
  final FieldEntity field;
  final String? initialValue;
  final Function(String) onCompleted;

  const SignatureFieldInput({
    super.key,
    required this.field,
    this.initialValue,
    required this.onCompleted,
  });

  @override
  State<SignatureFieldInput> createState() => _SignatureFieldInputState();
}

class _SignatureFieldInputState extends State<SignatureFieldInput> {
  late SignatureController _controller;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _hasSignature = widget.initialValue != null;
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
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Signature(
            controller: _controller,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    _hasSignature = false;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_controller.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign before continuing'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final signature = await _controller.toPngBytes();
                  if (signature != null) {
                    final base64Signature = base64Encode(signature);
                    final dataUrl = 'data:image/png;base64,$base64Signature';
                    widget.onCompleted(dataUrl);
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Save Signature'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}