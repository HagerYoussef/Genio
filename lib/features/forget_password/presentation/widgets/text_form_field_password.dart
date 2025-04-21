import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFormFieldPassword extends StatelessWidget {
  const TextFormFieldPassword({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.focusNode,
    this.nextFocusNode,
    this.validator,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final String? Function(String?)? validator;

  void _nextField(String value, BuildContext context) {
    if (value.length == 1 && nextFocusNode != null) {
      focusNode.unfocus(); // Unfocus current field
      FocusScope.of(context).requestFocus(nextFocusNode); // Move to next field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: TextFormField(
          cursorColor: Colors.black,
          controller: controller,
          focusNode: focusNode, // Set focus node
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xff99B5DD), width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xff99B5DD), width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color(0xffD4EBFF),
          ),
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return "This field is required";
            }
            return null;
          },
          onChanged: (value) => _nextField(value, context), // Auto move focus
        ),
      ),
    );
  }
}
