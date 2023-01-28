import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectableWidget extends ConsumerWidget {
  const SelectableWidget({
    Key? key,
    required this.name,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  final String name;
  final bool selected;
  final Function() onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: selected
                    ? Colors.blueAccent
                    : Colors.grey),
          ),
          child: Text(name),
        ),
      ),
    );
  }
}
