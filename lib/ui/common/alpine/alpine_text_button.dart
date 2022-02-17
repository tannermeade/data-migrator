import 'package:flutter/material.dart';

class AlpineTextButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final TextStyle style;

  const AlpineTextButton(
    this.text, {
    Key? key,
    this.onTap,
    this.style = const TextStyle(color: Color(0xFF5AB2D6), fontWeight: FontWeight.w200, fontSize: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          text,
          style: style,
        ),
      ),
    );
  }
}
