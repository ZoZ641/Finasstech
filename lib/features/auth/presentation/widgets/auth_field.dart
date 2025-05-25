import 'package:flutter/material.dart';

/* Text input field for Auth Feature */

class AuthField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool? isConfirmPassword;
  final TextEditingController? passController;
  const AuthField({
    super.key,
    required this.labelText,
    this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isConfirmPassword,
    this.passController,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: (value) {
        // Check if the value is null or empty
        if (value == null || value.isEmpty) {
          return "${widget.labelText} is missing!";
        }

        // Check if the field is a password or confirm password
        if (!(widget.isPassword || widget.isConfirmPassword == true)) {
          // Email validation
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return "Enter a valid email address!";
          }
        }

        // Check if the field is confirm password and if it matches the password
        if (widget.isConfirmPassword == true &&
            value != widget.passController!.text) {
          return "Passwords do not match!";
        }

        return null;
      },

      controller: widget.controller,
      obscureText:
          (widget.isPassword || widget.isConfirmPassword == true)
              ? _obscureText
              : false,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon:
            (widget.isPassword || widget.isConfirmPassword == true)
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
