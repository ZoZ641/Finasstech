import 'package:flutter/material.dart';

class TransactionField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  const TransactionField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return "$hintText is missing!";
        }
        return null;
      },
      controller: controller,
      decoration: InputDecoration(hintText: hintText, labelText: labelText),
    );
  }
}
