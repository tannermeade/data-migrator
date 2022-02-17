import 'package:flutter/material.dart';

import 'alpine_colors.dart';

class AlpineTextField extends StatelessWidget {
  const AlpineTextField({
    Key? key,
    required TextEditingController nameController,
    this.enabled = true,
  })  : _nameController = nameController,
        super(key: key);

  final TextEditingController _nameController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _nameController,
      cursorColor: Colors.black,
      cursorWidth: 1,
      enabled: enabled,
      // readOnly: !enabled,
      style: enabled
          ? const TextStyle(
              color: Colors.black,
              // fontWeight: FontWeight.w200,
              fontSize: 16,
            )
          : TextStyle(
              color: AlpineColors.textColor1,
              fontWeight: FontWeight.w200,
              fontSize: 16,
            ),
      decoration: InputDecoration(
        fillColor: enabled ? AlpineColors.textColor1 : AlpineColors.buttonColor3,
        filled: true,
        focusColor: enabled ? AlpineColors.textColor1 : AlpineColors.buttonColor3,
        hoverColor: enabled ? AlpineColors.textColor1 : AlpineColors.buttonColor3,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black38, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black38, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black38, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black38, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
