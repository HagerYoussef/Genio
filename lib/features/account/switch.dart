import 'package:flutter/material.dart';

class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    const WidgetStateProperty<Color?> trackColor = WidgetStateProperty<Color?>.fromMap(
      <WidgetStatesConstraint, Color>{WidgetState.selected: Color(0XFF0047AB)},
    );
    final WidgetStateProperty<Color?> overlayColor = WidgetStateProperty<Color?>.fromMap(
      <WidgetState, Color>{
        WidgetState.selected: Color(0XFF0047AB).withOpacity(0.54),
        WidgetState.disabled: Colors.grey.shade400,
      },
    );
    return Switch(
      value: light,
      overlayColor: overlayColor,
      trackColor: trackColor,
      thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
      onChanged: (bool value) {
        setState(() {
          light = value;
        });
      },
    );
  }
}