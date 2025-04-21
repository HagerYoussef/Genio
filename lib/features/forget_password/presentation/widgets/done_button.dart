import 'package:flutter/material.dart';

import '../../../login/presentation/widgets/text_auth.dart';

class DoneButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const DoneButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false, // Default to false
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0047AB),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)  // Show loading indicator
            : TextAuth(text: text, color: Colors.white,size: 16,fontWeight: FontWeight.w600,),
      ),
    );
  }
}
