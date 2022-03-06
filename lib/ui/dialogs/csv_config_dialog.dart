import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/csv_origin/csv_origin.dart';
import 'package:data_migrator/ui/common/alpine/alpine_file_picker_widget.dart';
import 'package:data_migrator/ui/common/alpine/alpine_button.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/alpine/alpine_close_button.dart';
import 'package:data_migrator/ui/common/alpine/alpine_file_picker_widget.dart';
import 'package:data_migrator/ui/dialog_handler.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CsvConfigDialogData extends DialogData {
  CsvConfigDialogData(this.schemaMap);
  final SchemaMap schemaMap;
  // final String content;
  // final Function() onDelete;
}

class CsvConfigDialog extends StatefulWidget {
  const CsvConfigDialog({
    Key? key,
    required this.data,
  }) : super(key: key);

  final CsvConfigDialogData data;

  @override
  State<CsvConfigDialog> createState() => _CsvConfigDialogState();
}

class _CsvConfigDialogState extends State<CsvConfigDialog> {
  late TextEditingController _nameController;
  late TextEditingController _idController;

  @override
  void initState() {
    _idController = TextEditingController(text: widget.data.schemaMap.id ?? "");
    _nameController = TextEditingController(text: widget.data.schemaMap.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      backgroundColor: AlpineColors.background1b,
      child: Container(
        width: 600,
        //padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Divider(
              color: AlpineColors.chartLineColor2,
              thickness: 2,
            ),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 40, top: 35, bottom: 25, right: 40),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "CSV Configuration",
            style: TextStyle(
              // color: AlpineColors.textColor1,
              fontSize: 20,
              fontWeight: FontWeight.w200,
            ),
          ),
          AlpineCloseButton(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, child) => Container(
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center(
              //     child: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text("CsvOrigin Interface"),
              //     ElevatedButton(
              //       onPressed: () => ref.read(sourceOriginProvider).loadCSV(),
              //       child: const Text("This is a Button"),
              //     ),
              //   ],
              // )),
              AlpineFilePickerWidget(
                getFile: () async {
                  if (sourceOriginProvider is StateProvider<CsvOrigin>) {
                    await (ref.read(sourceOriginProvider) as CsvOrigin).loadCSV();
                  }
                },
              ),
              const SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     // AppwriteButton(
              //     //   label: "Save",
              //     //   // textColor: Colors.white,
              //     //   color: AlpineColors.buttonColor2,
              //     //   isFilled: true,
              //     //   onTap: () {
              //     //     // widget.data.onDelete();
              //     //     widget.data.schemaMap.id = _idController.text;
              //     //     widget.data.schemaMap.name = _nameController.text;
              //     //     Navigator.pop(context);
              //     //   },
              //     // ),
              //     // const SizedBox(width: 10),
              //     // AppwriteButton(
              //     //   label: "Cancel",
              //     //   color: AlpineColors.buttonColor2,
              //     //   isFilled: false,
              //     //   onTap: () => Navigator.pop(context),
              //     // ),
              //   ],
              // ),
            ],
          )),
    );
  }
}
