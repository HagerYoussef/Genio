import 'package:flutter/material.dart';

import '../../../login/presentation/widgets/text_auth.dart';

class AiToolsContainer extends StatefulWidget {
  final String text;
  final String imagePath;
  final VoidCallback onTap;

  const AiToolsContainer({
    super.key,
    required this.text,
    required this.imagePath,
    required this.onTap,
  });

  @override
  _AiToolsContainerState createState() => _AiToolsContainerState();
}

class _AiToolsContainerState extends State<AiToolsContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 160,
        height: 140,
        child: InkWell(
          onTap: widget.onTap, // Call the passed function when tapped
          onTapDown: (_) => setState(() => _isPressed = true), // Press animation
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            transform: _isPressed
                ? (Matrix4.identity()..scale(0.95, 0.95))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: const Color(0xffD4EBFF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isPressed
                  ? [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)]
                  : [],
            ),
            width: 165,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      image: AssetImage(widget.imagePath)),
                  const SizedBox(
                    height: 5,
                  ),
                  TextAuth(text: widget.text, size: 14, fontWeight: FontWeight.w500, color: Colors.black)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
