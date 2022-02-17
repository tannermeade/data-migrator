import 'package:data_migrator/ui/common/values/routes.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:data_migrator/ui/common/alpine/alpine_table.dart';
import 'package:vrouter/vrouter.dart';

class AlpineDataTable extends StatefulWidget {
  const AlpineDataTable({
    Key? key,
    required this.headers,
    required this.data,
    this.allowOverflow = false,
    this.showCellBorder = true,
  }) : super(key: key);

  final List<String> headers;
  final List<List> data;
  final bool allowOverflow;
  final bool showCellBorder;

  @override
  State<AlpineDataTable> createState() => _AlpineDataTableState();
}

class _AlpineDataTableState extends State<AlpineDataTable> {
  @override
  Widget build(BuildContext context) {
    List<Row> rows = [];
    for (int i = 0; i < widget.data.length; i++) {
      rows.add(_buildRow(widget.data[i], i));
    }
    if (widget.headers.isNotEmpty) {
      rows = [_buildHeaderRow()] + rows;
    }
    return AlpineTable(
      allowOverflow: widget.allowOverflow,
      highlightHeader: false,
      rows: rows,
    );
  }

  double get _cellSize => 200;

  double get _rowHeight => 65;

  Row _buildRow(List row, int index) {
    List<Widget> widgets = [];
    for (int i = 0; i < row.length; i++) {
      Widget dataWidget;
      if (row[i] is String) {
        dataWidget = _buildStringDataCell(
          row[i],
          i == row.length - 1,
        );
      } else if (row[i] is Widget) {
        dataWidget = _buildWidgetCell(row[i], i == row.length - 1);
      } else {
        dataWidget = const SizedBox();
      }
      widgets.add(dataWidget);
    }
    return Row(children: widgets);
  }

  Widget _buildWidgetCell(Widget dataWidget, bool isLast) {
    return Expanded(
      child: Container(
        // width: _cellSize,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        alignment: Alignment.centerLeft,
        decoration: isLast || !widget.showCellBorder
            ? null
            : BoxDecoration(border: Border(right: BorderSide(width: 1, color: AlpineColors.chartLineColor2))),
        child: FittedBox(
          child: GestureDetector(
            // onTap: () => context.vRouter.to(
            //   Routes.home,
            //   queryParameters: {"collectionId": "123"},
            //   isReplacement: true,
            // ),
            child: MouseRegion(
              // cursor: SystemMouseCursors.click,
              child: dataWidget,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStringDataCell(String value, bool isLast) {
    return _buildWidgetCell(
        SelectableText(value,
            style: TextStyle(
              color: AlpineColors.textColor2, //blueColor
              fontWeight: FontWeight.w200,
            )),
        isLast);
  }

  Row _buildHeaderRow() {
    List<Widget> cells = [];

    for (int i = 0; i < widget.headers.length; i++) {
      cells.add(_buildHeaderCell(widget.headers[i], i == widget.headers.length - 1));
    }

    return Row(children: cells);
  }

  Widget _buildHeaderCell(String label, bool isLast) {
    bool isLast = widget.headers.last == label;
    return Expanded(
      child: Container(
        // width: _cellSize,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: isLast
            ? null
            : BoxDecoration(border: Border(right: BorderSide(width: 1, color: AlpineColors.chartLineColor2))),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: AlpineColors.textColor1, fontWeight: FontWeight.w300),
            ),
            // Icon(Icons.text_fields, color: AlpineColors.textColor2, size: 12),
          ],
        ),
      ),
    );
  }
}
