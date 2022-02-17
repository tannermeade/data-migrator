import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';

class ArrowedAttributeWidget extends StatelessWidget {
  const ArrowedAttributeWidget({
    Key? key,
    required this.child,
    this.onTap,
    required this.arrowColor,
  }) : super(key: key);

  final Widget child;
  final Color arrowColor;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: arrowColor,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.arrow_forward_ios, size: 10, color: AlpineColors.background1a),
            ),
            const SizedBox(width: 10),
            child,
            // onTap == null
            //     ? SelectableText(
            //         label,
            //         style: TextStyle(
            //           color: labelColor,
            //           fontSize: 14,
            //           fontWeight: FontWeight.w200,
            //         ),
            //       )
            //     : Text(
            //         label,
            //         style: TextStyle(
            //           color: labelColor,
            //           fontSize: 14,
            //           fontWeight: FontWeight.w200,
            //         ),
            //       ),
          ],
        ),
      ),
    );
  }
}
