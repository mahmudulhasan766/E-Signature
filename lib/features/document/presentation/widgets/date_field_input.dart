import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/field_entity.dart';

class DateFieldInput extends StatefulWidget {
  final FieldEntity field;
  final String? initialValue;
  final Function(String) onCompleted;

  const DateFieldInput({
    super.key,
    required this.field,
    this.initialValue,
    required this.onCompleted,
  });

  @override
  State<DateFieldInput> createState() => _DateFieldInputState();
}

class _DateFieldInputState extends State<DateFieldInput> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      try {
        _selectedDate = DateTime.parse(widget.initialValue!);
      } catch (e) {
        _selectedDate = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.purple),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                      : 'Select a date',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate != null ? Colors.black : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _selectedDate != null
              ? () {
            widget.onCompleted(_selectedDate!.toIso8601String());
          }
              : null,
          icon: const Icon(Icons.check),
          label: const Text('Save Date'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}