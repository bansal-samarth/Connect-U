import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final RegExp validateRegEx;
  final bool obscureText;
  final void Function(String?) onSaved;

  const CustomFormField({
    super.key,
    required this.hintText,
    this.icon,
    required this.validateRegEx,
    this.obscureText = false,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      obscureText: obscureText,
      validator: (value) {
        if (value != null && validateRegEx.hasMatch(value)) {
          return null;
        }
        return "Enter a valid ${hintText.toLowerCase()}";
      },
      decoration: InputDecoration(
        icon: icon != null ? Icon(icon) : null,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
