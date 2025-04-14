import 'package:flutter/material.dart';

/* Text input field for Auth Feature */

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool? isConfirmPassword;
  final TextEditingController? passController;
  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isConfirmPassword,
    this.passController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: (value) {
        if (value!.isEmpty) {
          return "$hintText is missing!";
        }
        if (isConfirmPassword == true && value != passController!.text) {
          return "Passwords do not match!";
        }
        return null;
      },
      controller: controller,
      obscureText: isPassword || isConfirmPassword == true ? true : false,
      decoration: InputDecoration(hintText: hintText /*labelText: hintText*/),
    );
  }
}
