import 'package:data_migrator/domain/data_types/schema_field.dart';

import 'alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AlpineTable extends StatelessWidget {
  const AlpineTable({
    Key? key,
    this.allowOverflow = false,
    required this.rows,
    this.highlightHeader = true,
  }) : super(key: key);

  final List<Row> rows;
  final bool allowOverflow;
  final bool highlightHeader;

  @override
  Widget build(BuildContext context) {
    List<Widget> dataWidgets = [];
    for (int i = 0; i < rows.length; i++) {
      if (i != 0) dataWidgets.add(_buildDivider());
      dataWidgets.add(_buildRow(rows[i], i));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        color: AlpineColors.chartLineColor2,
        child: _buildScroller(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dataWidgets,
          ),
        ),
      ),
    );
  }

  Widget _buildScroller({required Widget child}) {
    return allowOverflow
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: child,
          )
        : child;
  }

  double get _rowHeight => 65;
  Widget _buildDivider() => const SizedBox(height: 1);

  Widget _buildRow(Row row, int index) {
    return Container(
      decoration: BoxDecoration(
          color: (highlightHeader ? index.isEven && index != 0 : index.isOdd)
              ? AlpineColors.background1e
              : AlpineColors.background1a),
      height: _rowHeight,
      child: rows[index],
    );
  }
}
