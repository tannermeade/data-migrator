import 'package:data_migrator/ui/common/platform_window/window.dart';
import 'package:flutter/material.dart';

class WindowsTitleBar extends StatelessWidget {
  const WindowsTitleBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: const [LeftSide(), RightSide()],
      ),
    );
  }
}
