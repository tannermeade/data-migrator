import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';

class AlpineSwitch extends StatefulWidget {
  const AlpineSwitch({
    Key? key,
    this.initiallyOn = false,
    this.onChange,
    this.disabled = false,
  }) : super(key: key);

  final bool initiallyOn;
  final bool disabled;
  final Function(bool)? onChange;

  @override
  State<AlpineSwitch> createState() => _AlpineSwitchState();
}

class _AlpineSwitchState extends State<AlpineSwitch> {
  late bool on;

  @override
  void initState() {
    on = widget.initiallyOn;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.disabled
          ? null
          : () {
              setState(() => on = !on);
              if (widget.onChange != null) widget.onChange!(on);
            },
      child: MouseRegion(
        cursor: widget.disabled ? MouseCursor.defer : SystemMouseCursors.click,
        child: AnimatedContainer(
          width: 52,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: widget.disabled
                ? AlpineColors.background4a
                : on
                    ? const Color(0xFF34b86d)
                    : const Color(0xFFbec3e0),
          ),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          duration: const Duration(milliseconds: 75),
          child: Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: widget.disabled ? AlpineColors.background2a : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
