import 'alpine_colors.dart';
import 'package:flutter/material.dart';

class AlpineSelectionWidget extends StatefulWidget {
  const AlpineSelectionWidget({
    Key? key,
    required this.options,
    required this.initalIndex,
    this.isCircular = false,
  }) : super(key: key);

  final List<String> options;
  final int initalIndex;
  final bool isCircular;

  @override
  State<AlpineSelectionWidget> createState() => _AlpineSelectionWidgetState();
}

class _AlpineSelectionWidgetState extends State<AlpineSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   decoration: BoxDecoration(
    //     color: AlpineColors.textColor1,
    //     borderRadius: BorderRadius.circular(8),
    //   ),
    //   padding: const EdgeInsets.symmetric(horizontal: 10),
    //   // alignment: Alignment.center,
    //   child: DropdownButton<Enum>(
    //     iconEnabledColor: Colors.transparent,
    //     iconDisabledColor: Colors.transparent,
    //     focusColor: Colors.transparent,
    //     dropdownColor: AlpineColors.textColor1,
    //     value: value,
    //     underline: const SizedBox(),
    //     icon: const SizedBox(),
    //     hint: Text(
    //       "No Type Selected",
    //       style: TextStyle(color: AlpineColors.warningColor),
    //     ),
    //     items: items
    //         .map((e) => DropdownMenuItem<Enum>(
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [Text(e.name, style: TextStyle(color: AlpineColors.background1a))],
    //             ),
    //             value: e))
    //         .toList(),
    //     onChanged: (Enum? value) {
    //       if (field.types.first is SchemaTyped && value != null) {
    //         (field.types.first as SchemaTyped).typeByEnum = value;
    //         setState(() {});
    //       }
    //     },
    //   ),
    // );
    return GestureDetector(
      onTap: _expandSelection,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: widget.isCircular ? _buildCircular() : _buildRounded(),
      ),
    );
  }

  Widget _buildRounded() {
    return Container(
      decoration: BoxDecoration(
        color: AlpineColors.textColor1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.options[widget.initalIndex],
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              )),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildCircular() {
    return Container(
      width: 207,
      height: 40,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: AlpineColors.textColor1,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(widget.options[widget.initalIndex], style: const TextStyle(fontWeight: FontWeight.w300))),
          const Icon(Icons.keyboard_arrow_down)
        ],
      ),
    );
  }

  _expandSelection() {
    print("expanding selection");
  }
}
