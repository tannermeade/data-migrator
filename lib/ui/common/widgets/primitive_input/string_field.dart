import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum StringFilterType {
  string,
  url,
  email,
  ip,
}

class StringField extends StatelessWidget {
  const StringField({
    Key? key,
    this.filter = StringFilterType.string,
    this.controller,
    this.multiLine = false,
    this.onChanged,
    this.disabled = false,
  }) : super(key: key);

  final StringFilterType filter;
  final TextEditingController? controller;
  final bool multiLine;
  final void Function(String)? onChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: !disabled,
      onChanged: onChanged,
      controller: controller ?? TextEditingController(),
      cursorColor: Colors.black,
      minLines: multiLine && filter == StringFilterType.string ? 2 : null,
      maxLines: multiLine && filter == StringFilterType.string ? 10 : null,
      cursorWidth: 1,
      style: disabled
          ? TextStyle(color: AlpineColors.textFieldColor1.withOpacity(0.3))
          : const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "",
        hintStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w200),
        // border: Border.all(color: Colors.black38, width: 1),
        // color: AlpineColors.background4a,
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
          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
        ),
      ),
    );
  }
}
