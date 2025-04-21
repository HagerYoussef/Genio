import 'package:flutter/material.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFormFieldAuth extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const TextFormFieldAuth({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<TextFormFieldAuth> createState() => _TextFormFieldAuthState();
}

class _TextFormFieldAuthState extends State<TextFormFieldAuth> {
  late ValueNotifier<bool> _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = ValueNotifier(widget.isPassword);
  }

  @override
  void dispose() {
    _isObscured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextAuth(text: widget.label, size: 16, fontWeight: FontWeight.w500, color: Colors.black,),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: _isObscured,
          builder: (context, isObscured, child) {
            return TextFormField(
              cursorColor: const Color(0xff99B5DD),
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword ? isObscured : false,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.black54,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: Color(0x800047ab), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: Color(0xff99B5DF), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    _isObscured.value = !isObscured;
                  },
                )
                    : null,
              ),
              validator: widget.validator ??
                      (value) {
                    if (value == null || value.isEmpty) {
                      return "This field is required";
                    }
                    return null;
                  },
            );
          },
        ),
      ],
    );
  }
}