import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class CodeContainer extends StatefulWidget {
  const CodeContainer({
    Key? key,
    required this.child,
    required this.language,
    required this.copyText,
  }) : super(key: key);

  final Widget child;
  final String language;
  final String copyText;

  @override
  State<CodeContainer> createState() => _CodeContainerState();
}

class _CodeContainerState extends State<CodeContainer> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => isHovering = true),
      onExit: (event) => setState(() => isHovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AlpineColors.background1a,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            widget.child,
            Container(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                // width: 30,
                // height: 20,
                decoration: BoxDecoration(
                  color: AlpineColors.buttonColor2,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(widget.language, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w200)),
              ),
            ),
            Positioned.fill(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: AnimatedOpacity(
                  opacity: isHovering ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedContainer(
                    transform: Transform.translate(
                      offset: Offset(0, isHovering ? 0 : 20),
                    ).transform,
                    alignment: Alignment.bottomCenter,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.copyText));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Copied code to your clipboard.")));
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration:
                              BoxDecoration(borderRadius: BorderRadius.circular(20), color: AlpineColors.buttonColor2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(FontAwesome.copy, size: 10),
                              SizedBox(width: 5),
                              Text("Click here to Copy", style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
