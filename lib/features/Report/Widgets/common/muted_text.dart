import 'package:flutter/material.dart';

class MutedText extends StatelessWidget {
  const MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
  }
}
