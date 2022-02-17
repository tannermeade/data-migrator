import 'package:data_migrator/ui/common/values/routes.dart';

import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vrouter/src/core/extended_context.dart';

import 'package:data_migrator/ui/common/alpine/alpine_table.dart';

class CollectionDataTable extends StatefulWidget {
  CollectionDataTable({
    Key? key,
  }) : super(key: key);

  @override
  State<CollectionDataTable> createState() => _CollectionDataTableState();
}

class _CollectionDataTableState extends State<CollectionDataTable> {
  final List<String> headers = [
    "title",
    "subtitle",
    "authors",
    "recipients",
    "edition",
    "partIds",
    "bookGroupIds",
    "printPages",
    "language",
    "summary",
    "compressedId",
  ];

  final List<Map<String, String>> data = [
    {
      "title": "123",
      "subtitle": "123",
      "authors": "123",
      "recipients": "123",
      "edition": "123",
      "partIds": "123",
      "bookGroupIds": "123",
      "printPages": "123",
      "language": "123",
      "summary": "123",
      "compressedId": "123",
    },
    {
      "title": "123",
      "subtitle": "123",
      "authors": "123",
      "recipients": "123",
      "edition": "123",
      "partIds": "123",
      "bookGroupIds": "123",
      "printPages": "123",
      "language": "123",
      "summary": "123",
      "compressedId": "123",
    },
    {
      "title": "123",
      "subtitle": "123",
      "authors": "123",
      "recipients": "123",
      "edition": "123",
      "partIds": "123",
      "bookGroupIds": "123",
      "printPages": "123",
      "language": "123",
      "summary": "123",
      "compressedId": "123",
    },
    {
      "title": "123",
      "subtitle": "123",
      "authors": "123",
      "recipients": "123",
      "edition": "123",
      "partIds": "123",
      "bookGroupIds": "123",
      "printPages": "123",
      "language": "123",
      "summary": "123",
      "compressedId": "123",
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Row> rows = [];
    for (int i = 0; i < data.length; i++) {
      rows.add(_buildRow(data[i], i));
      //dataWidgets.add(_buildDivider());
    }

    return AlpineTable(
      allowOverflow: true,
      rows: [_buildHeaderRow()] + rows,
    );
  }

  double get _cellSize => 200;

  double get _rowHeight => 65;

  Row _buildRow(Map<String, String> row, int index) {
    List<Widget> widgets = [];
    List entries = row.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      widgets.add(_buildDataCell(
        entries[i].key,
        entries[i].value,
        i == entries.length - 1,
      ));
    }
    return Row(children: widgets);
  }

  Widget _buildDataCell(String label, String value, bool isLast) {
    return Container(
      width: _cellSize,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      decoration: isLast
          ? null
          : BoxDecoration(border: Border(right: BorderSide(width: 1, color: AlpineColors.chartLineColor2))),
      child: FittedBox(
        child: GestureDetector(
          onTap: () => context.vRouter.to(
            Routes.home,
            queryParameters: {"collectionId": "123"},
            isReplacement: true,
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(value,
                style: TextStyle(
                  color: AlpineColors.blueColor,
                  fontWeight: FontWeight.w200,
                )),
          ),
        ),
      ),
    );
  }

  Row _buildHeaderRow() {
    List<Widget> cells = [];

    for (int i = 0; i < headers.length; i++) {
      cells.add(_buildHeaderCell(headers[i], i == headers.length - 1));
    }

    return Row(children: cells);
  }

  Widget _buildHeaderCell(String label, bool isLast) {
    bool isLast = headers.last == label;
    return Container(
      width: _cellSize,
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
          Icon(Icons.text_fields, color: AlpineColors.textColor2, size: 12),
        ],
      ),
    );
  }
}
