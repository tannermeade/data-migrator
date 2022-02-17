import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionsInput extends StatefulWidget {
  const PermissionsInput({
    Key? key,
    this.isCollapsable = false,
  }) : super(key: key);

  final bool isCollapsable;

  @override
  State<PermissionsInput> createState() => _PermissionsInputState();
}

class _PermissionsInputState extends State<PermissionsInput> with TickerProviderStateMixin {
  late bool open;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
    value: widget.isCollapsable ? 0 : 1,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    open = !widget.isCollapsable;
    //if (open) _controller.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isCollapsable)
          GestureDetector(
            onTap: () => setState(() {
              if (_controller.isAnimating) return;
              open = !open;
              if (_controller.isCompleted) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            }),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 40),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Permissions",
                      style: TextStyle(
                        color: AlpineColors.textColor1,
                        fontWeight: FontWeight.w200,
                        fontSize: 20,
                      ),
                    ),
                    Icon(
                      open ? FontAwesome.minus : FontAwesome.plus,
                      color: AlpineColors.textColor1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizeTransition(
          sizeFactor: _animation,
          child: SizedBox(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildInput(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInput() {
    return [
      RichText(
          text: TextSpan(children: [
        TextSpan(
          text: "Read Access (",
          style: TextStyle(
            color: AlpineColors.textColor1,
            fontSize: 16,
            fontWeight: FontWeight.w200,
          ),
        ),
        TextSpan(
          text: "Learn more",
          style: TextStyle(
            color: AlpineColors.blueColor,
            fontSize: 14,
            fontWeight: FontWeight.w200,
          ),
          mouseCursor: SystemMouseCursors.click,
          recognizer: TapGestureRecognizer()..onTap = () => launch("https://appwrite.io/docs/permissions"),
        ),
        TextSpan(
          text: ")",
          style: TextStyle(
            color: AlpineColors.textColor1,
            fontSize: 16,
            fontWeight: FontWeight.w200,
          ),
        ),
      ])),
      const SizedBox(height: 15),
      TextField(
        cursorColor: Colors.black,
        cursorWidth: 1,
        decoration: InputDecoration(
          hintText: "User ID, Team ID or Role",
          hintStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w200),
          fillColor: AlpineColors.textColor1,
          filled: true,
          focusColor: AlpineColors.textColor1,
          hoverColor: AlpineColors.textColor1,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      const SizedBox(height: 15),
      Text(
        "Add 'role:all' for wildcard access",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 10,
          fontWeight: FontWeight.w200,
        ),
      ),
      const SizedBox(height: 30),
      RichText(
          text: TextSpan(children: [
        TextSpan(
          text: "Write Access (",
          style: TextStyle(
            color: AlpineColors.textColor1,
            fontSize: 16,
            fontWeight: FontWeight.w200,
          ),
        ),
        TextSpan(
          text: "Learn more",
          style: TextStyle(
            color: AlpineColors.blueColor,
            fontSize: 14,
            fontWeight: FontWeight.w200,
          ),
          mouseCursor: SystemMouseCursors.click,
          recognizer: TapGestureRecognizer()..onTap = () => launch("https://appwrite.io/docs/permissions"),
        ),
        TextSpan(
          text: ")",
          style: TextStyle(
            color: AlpineColors.textColor1,
            fontSize: 16,
            fontWeight: FontWeight.w200,
          ),
        ),
      ])),
      const SizedBox(height: 15),
      const SelectorField(),
      const SizedBox(height: 15),
      Text(
        "Add 'role:all' for wildcard access",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 10,
          fontWeight: FontWeight.w200,
        ),
      ),
    ];
  }
}

class SelectorField extends StatefulWidget {
  const SelectorField({
    Key? key,
    this.hintText = "User ID, Team ID or Role",
  }) : super(key: key);

  final String hintText;

  @override
  State<SelectorField> createState() => _SelectorFieldState();
}

class _SelectorFieldState extends State<SelectorField> {
  List<String> entries = ["role:all"];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AlpineColors.textColor1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          ..._buildEntries(),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              cursorColor: Colors.black,
              cursorWidth: 1,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w200),
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEntries() {
    return entries
        .map(
          (str) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF181818),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              str,
              style: TextStyle(
                color: AlpineColors.textColor2,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        )
        .toList();
  }
}
