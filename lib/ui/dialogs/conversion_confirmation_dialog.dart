import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/confirmation/schema_change.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/appwrite_origin.dart';
import 'package:data_migrator/ui/common/alpine/alpine_button.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/alpine/alpine_close_button.dart';
import 'package:data_migrator/ui/common/widgets/schema_map_widget.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversionConfirmationDialog extends StatefulWidget {
  const ConversionConfirmationDialog({
    Key? key,
    required this.confirmationData,
    required this.totalConfirmations,
    required this.confirmationNumber,
    this.onCancel,
  }) : super(key: key);

  final ConfirmationData confirmationData;
  final int totalConfirmations;
  final int confirmationNumber;
  final Function()? onCancel;

  @override
  State<ConversionConfirmationDialog> createState() => _ConversionConfirmationDialogState();
}

class _ConversionConfirmationDialogState extends State<ConversionConfirmationDialog> {
  bool _performingChanges = false;

  @override
  void initState() {
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
        child: SingleChildScrollView(
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
          Text(
            // "Conversion Confirmation Dialog",
            _getHeaderText(),
            style: const TextStyle(
              // color: AlpineColors.textColor1,
              fontSize: 20,
              fontWeight: FontWeight.w200,
            ),
          ),
          if (!_performingChanges) AlpineCloseButton(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer(builder: (context, ref, child) {
      var appwriteOrigin = ref.read(destinationOriginProvider);
      return Container(
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.confirmationData.sentence),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.confirmationData.schemaBefore != null && widget.confirmationData.schemaBefore is SchemaMap)
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Before"),
                        SchemaMapWidget(schemaMap: widget.confirmationData.schemaBefore as SchemaMap, forOrigin: null),
                      ],
                    )),
                  if (widget.confirmationData.schemaAfter != null && widget.confirmationData.schemaAfter is SchemaMap)
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("After"),
                        SchemaMapWidget(schemaMap: widget.confirmationData.schemaAfter as SchemaMap, forOrigin: null),
                      ],
                    )),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                child: Column(
                  children: [
                    const Text("Changes to Fields"),
                    const SizedBox(height: 15),
                    if (widget.confirmationData.schemaMapChange.fieldChanges.isEmpty) const Text("No field changes."),
                    if (widget.confirmationData.schemaMapChange.fieldChanges.isNotEmpty)
                      ...widget.confirmationData.schemaMapChange.fieldChanges.map((c) => _buildFieldChange(c)).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              if (appwriteOrigin.isAuthenticated) _buildBottomBar(appwriteOrigin),
            ],
          ));
    });
  }

  Widget _buildFieldChange(SchemaChange change) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: AlpineColors.background4a,
        borderRadius: BorderRadius.circular(7),
        // border: Border.all(color: AlpineColors.background4a),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(change.changeType.name),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(change.id),
          ),
          Expanded(
              child: Container(
            // color: Colors.blue[Random(123).nextInt(9) * 100],
            child: Text(change.changes.map((varChange) => "${varChange.key}: ${varChange.value}").toList().join("\n")),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AppwriteOrigin appwriteOrigin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!_performingChanges)
          AlpineButton(
            label: "Cancel Conversion",
            width: 200,
            textColor: AlpineColors.buttonColor2,
            color: AlpineColors.buttonColor2,
            isFilled: false,
            onTap: () async {
              // cancel
              if (widget.onCancel != null) widget.onCancel!();
              Navigator.pop(context);
            },
          ),
        const SizedBox(width: 15),
        AlpineButton(
          label: "Confirm",
          child: _performingChanges ? const CircularProgressIndicator.adaptive() : null,
          width: 120,
          textColor: Colors.white,
          color: AlpineColors.warningColor,
          isFilled: true,
          onTap: () async {
            // onConfirm
            if (_performingChanges) return;
            setState(() => _performingChanges = true);
            await widget.confirmationData.onConfirmed();
            Navigator.pop(context);
            _performingChanges = false;
          },
        )
      ],
    );
  }

  String _getHeaderText() {
    if (widget.totalConfirmations == 1) {
      return "Only ${widget.totalConfirmations} Confirmation (${widget.confirmationNumber} of ${widget.totalConfirmations})";
    }
    return widget.confirmationNumber.toString() + " out of " + widget.totalConfirmations.toString() + " Confirmations";
  }
}
