import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

enum ToolTipType {
  regular,
  content,
}

class ToolTipTarget extends StatefulWidget {
  const ToolTipTarget({
    Key? key,
    required this.child,
    this.showTooltipOnHover = false,
    this.showTooltipOnTap = false,
    this.toolTip = const SizedBox(),
    this.direction = TooltipDirection.up,
    this.toolTipType = ToolTipType.regular,
  }) : super(key: key);
  final Widget child;
  final Widget toolTip;
  final bool showTooltipOnHover;
  final bool showTooltipOnTap;
  final TooltipDirection direction;
  final ToolTipType toolTipType;

  @override
  ToolTipTargetState createState() => ToolTipTargetState();
}

class ToolTipTargetState extends State<ToolTipTarget> {
  bool toolTipOpen = false;

  @override
  Widget build(BuildContext context) {
    switch (widget.toolTipType) {
      case ToolTipType.regular:
        return _regularToolTip();
      case ToolTipType.content:
        return _contentToolTip();
      default:
        return _regularToolTip();
    }
  }

  Widget _regularToolTip() {
    return SimpleTooltip(
      tooltipTap: () {
        print("Tooltip tap");
      },
      //targetCenter: Offset.zero,
      arrowTipDistance: 0.1,
      arrowLength: 5,
      arrowBaseWidth: 10,
      backgroundColor: AlpineColors.textColor1,
      borderColor: AlpineColors.textColor1,
      animationDuration: const Duration(milliseconds: 50),
      ballonPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      minimumOutSidePadding: 0.0,
      borderWidth: 0,
      borderRadius: 5,
      show: toolTipOpen,
      tooltipDirection: widget.direction,
      child: MouseRegion(
        cursor: widget.showTooltipOnTap || widget.showTooltipOnHover ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: openToolTip,
        onExit: closeToolTip,
        child: GestureDetector(
          onTap: widget.showTooltipOnTap ? () => setState(() => toolTipOpen = !toolTipOpen) : () {},
          child: widget.child,
        ),
      ),
      content: Material(color: Colors.transparent, child: widget.toolTip),
    );
  }

  Widget _contentToolTip() {
    return SimpleTooltip(
      hideOnTooltipTap: true,
      tooltipTap: () {
        print("Tooltip tap");
      },
      //targetCenter: Offset.zero,
      arrowTipDistance: 0.1,
      arrowLength: 5,
      arrowBaseWidth: 10,
      backgroundColor: AlpineColors.background1d,
      borderColor: AlpineColors.background1d,
      customShadows: const [
        BoxShadow(
          color: Color(0x55000000),
          offset: Offset(2, 2),
          blurRadius: 4,
        ),
      ],
      animationDuration: const Duration(milliseconds: 50),
      ballonPadding: EdgeInsets.zero,
      minimumOutSidePadding: 0.0,
      borderWidth: 0,
      borderRadius: 5,
      show: toolTipOpen,
      tooltipDirection: widget.direction,
      child: MouseRegion(
        cursor: widget.showTooltipOnTap || widget.showTooltipOnHover ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: openToolTip,
        onExit: closeToolTip,
        child: GestureDetector(
          onTap: widget.showTooltipOnTap ? () => setState(() => toolTipOpen = !toolTipOpen) : () {},
          child: widget.child,
        ),
      ),
      content: Material(color: Colors.transparent, child: widget.toolTip),
    );
  }

  void openToolTip(PointerEnterEvent? e, {bool byPassCheck = false}) {
    if (widget.showTooltipOnHover || byPassCheck) setState(() => toolTipOpen = true);
  }

  void closeToolTip(PointerExitEvent? e, {bool byPassCheck = false}) {
    if (widget.showTooltipOnHover || byPassCheck) setState(() => toolTipOpen = false);
  }
}
