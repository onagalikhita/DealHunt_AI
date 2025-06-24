import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField({
    super.key,
    this.labelText,
    this.icon,
    this.obscureText,
    this.suffixIcon,
    this.controller,
  });

  final labelText;
  final icon;
  final suffixIcon;
  final obscureText;
  final controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFFFFFF), width: 1.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFFFFFF), width: 1.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          fillColor: Color(0xFFFFFFFF),
          labelText: labelText,
          labelStyle: GoogleFonts.inter(
            color: Color(0xFF000000),
            fontSize: 14.0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
            child: Icon(icon, color: Color(0xFF000000)),
          ),
          filled: true,
        ),
      ),
    );
  }
}
