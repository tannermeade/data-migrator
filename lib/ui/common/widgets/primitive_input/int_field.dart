import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntField extends StatelessWidget {
  const IntField({
    Key? key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.disabled = false,
  }) : super(key: key);

  final int? initialValue;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller ?? TextEditingController(text: initialValue == null ? "" : initialValue.toString()),
      enabled: !disabled,
      onChanged: onChanged,
      cursorColor: Colors.black,
      cursorWidth: 1,
      style: disabled
          ? TextStyle(color: AlpineColors.textFieldColor1.withOpacity(0.3))
          : const TextStyle(color: Colors.black),
      inputFormatters: [
        TextInputFormatter.withFunction(
          (oldTEV, newTEV) {
            int? i = int.tryParse(newTEV.text);
            if (i == null && (newTEV.text.isEmpty || newTEV.text == "-")) i = 0;
            return i == null ? oldTEV : newTEV;
          },
        ),
      ],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        fillColor: disabled ? AlpineColors.background4a : AlpineColors.textColor1,
        filled: true,
        focusColor: disabled ? Colors.transparent : AlpineColors.textColor1,
        hoverColor: disabled ? Colors.transparent : AlpineColors.textColor1,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
