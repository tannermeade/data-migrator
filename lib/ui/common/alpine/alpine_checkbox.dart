import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';

class AlpineCheckbox extends StatelessWidget {
  const AlpineCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  final bool? value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        const interactiveStates = {MaterialState.selected};
        if (states.any(interactiveStates.contains)) return AlpineColors.buttonColor2;
        return AlpineColors.buttonColor2;
      }),
      focusColor: Colors.transparent,
      // hoverColor: Colors.transparent,
      checkColor: AlpineColors.background1a,
      activeColor: AlpineColors.buttonColor2,
      // overlayColor: AlpineColors.buttonColor2,
    );
  }
}
