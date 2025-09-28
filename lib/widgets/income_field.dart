//widgets/income_field.dart

import 'package:flutter/material.dart';

class IncomeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String)? onChanged;

  const IncomeField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }
}
