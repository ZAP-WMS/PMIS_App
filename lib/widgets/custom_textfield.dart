import 'dart:ui';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  String? role;
  bool isObscure;
  String labeltext;
  final String? Function(String?)? validatortext;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  CustomTextField(
      {super.key,
      required this.controller,
      required this.labeltext,
      this.validatortext,
      required this.keyboardType,
      required this.textInputAction,
      this.role,
      this.isObscure = false});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isObscure,
      readOnly: widget.role == 'admin' ? true : false,
      autofocus: false,
      controller: widget.controller,
      onChanged: (value) => widget.labeltext,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          labelText: widget.labeltext,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey))),
      validator: widget.validatortext,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
    );
  }
}
