import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'alpine_button.dart';
import 'alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class AlpineFilePickerWidget extends StatefulWidget {
  const AlpineFilePickerWidget({
    Key? key,
    required this.getFile,
    this.multipleFiles = true,
    this.maxSizeInMb,
  }) : super(key: key);

  final Future<FilePickerResult?> Function() getFile;
  final bool multipleFiles;
  final double? maxSizeInMb;

  @override
  State<AlpineFilePickerWidget> createState() => _AlpineFilePickerWidgetState();
}

class _AlpineFilePickerWidgetState extends State<AlpineFilePickerWidget> {
  List<PlatformFile> files = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AlpineButton(
              label: files.isEmpty
                  ? widget.multipleFiles
                      ? "Choose files"
                      : "Choose file"
                  : widget.multipleFiles
                      ? "Change file(s)"
                      : "Change file",
              color: AlpineColors.textColor1,
              isFilled: files.isEmpty,
              onTap: () async {
                var fileResult = await widget.getFile();
                if (fileResult != null && fileResult.files.isNotEmpty) {
                  setState(() => files = fileResult.files);
                }
                // FilePickerResult? result = await FilePicker.platform.pickFiles();

                // if (result != null) {
                //   file = File(result.files.single.name);
                //   setState(() {});
                // } else {
                //   // User canceled the picker
                // }
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 60,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  files.isNotEmpty
                      ? files.map((f) => basename(f.name)).toList().toString()
                      : widget.multipleFiles
                          ? "No file(s) chosen"
                          : "No file chosen",
                  style: TextStyle(
                    color: AlpineColors.textColor1,
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (widget.maxSizeInMb != null)
          SelectableText(
            "(Max file size allowed: ${widget.maxSizeInMb}MB)",
            style: TextStyle(
              color: AlpineColors.textColor2,
              fontSize: 10,
              fontWeight: FontWeight.w100,
              height: 1.5,
            ),
          ),
      ],
    );
  }
}
