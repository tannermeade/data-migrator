import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppBarItem extends StatefulWidget {
  const AppBarItem({
    this.iconData,
    required this.text,
    this.style = const TextStyle(),
    this.onTap,
  });

  final String text;
  final IconData? iconData;
  final TextStyle style;

  final VoidCallback? onTap;

  @override
  State<AppBarItem> createState() => _AppBarItemState();
}

class _AppBarItemState extends State<AppBarItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    animation = IntTween(
      begin: 150,
      end: 100,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (PointerEnterEvent e) => _controller.forward(),
        onExit: (PointerExitEvent e) => _controller.reverse(),
        child: Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(top: animation.value / 10, bottom: 15, left: 0, right: 22),
          child: Row(
            children: [
              if (widget.iconData != null) Icon(widget.iconData, color: AlpineColors.textColor2, size: 15),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: widget.style.copyWith(color: AlpineColors.textColor2, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
