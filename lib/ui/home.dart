import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/domain/conversion/conversion/convert_schema_map.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/values/enums.dart';
import 'package:data_migrator/ui/common/widgets/convert_schema_map_widget.dart';
import 'package:data_migrator/ui/common/widgets/schema_map_widget.dart';
import 'package:data_migrator/ui/dialog_handler.dart';
import 'package:data_migrator/ui/dialogs/appwrite_config_dialog.dart';
import 'package:data_migrator/ui/dialogs/conversion_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'common/alpine/alpine_button.dart';
import 'common/values/providers.dart';
import 'common/values/routes.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return FloatingActionButton(
            backgroundColor: AlpineColors.buttonColor2,
            child: const Icon(Icons.play_arrow),
            onPressed: () async {
              // start conversion
              var sourceOrigin = ref.read(sourceOriginProvider);
              var destinationOrigin = ref.read(destinationOriginProvider);
              var converter = ref.read(converterProvider);
              try {
                await converter.startConversion(
                  destination: destinationOrigin,
                  source: sourceOrigin,
                  sourceAddress: [0],
                  onConfirm: _handleConversionConfirmations,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
              // bool validConversions = false;
              // try {
              //   validConversions = converter.validateConversions(sourceOrigin, destinationOrigin);
              // } catch (e) {
              //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              // }
              // if (validConversions) {
              //   List<int> sourceAddress = [0];
              //   converter.startConversion(sourceAddress, sourceOrigin, destinationOrigin);
              // }
            },
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: AlpineColors.background3b,
        title: const Text("Data Migrator"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSourceColumn(),
                ),
                Expanded(
                  flex: 3,
                  child: _buildConverterColumn(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildDestinationColumn(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceColumn() {
    return Container(
      width: 100,
      height: double.infinity,
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            var sourceOrigin = ref.watch(sourceOriginProvider);
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: const Text(
                    "Appwrite (source)",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: AlpineButton(
                    onTap: () => toPopUp(
                      context,
                      Routes.appwriteConfigDialog,
                      AppwriteConfigDialogData(sourceOrigin),
                    ),
                    label: "Configure",
                    color: AlpineColors.buttonColor2,
                    isFilled: true,
                    // fontSize: 14,
                    // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
                ...sourceOrigin
                    .getSchema()
                    .map((m) => SchemaMapWidget(
                          schemaMap: m,
                          forOrigin: Origin.source,
                        ))
                    .toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConverterColumn() {
    return Container(
      // width: 50,
      height: double.infinity,
      // decoration: BoxDecoration(color: AlpineColors.background1d, borderRadius: BorderRadius.circular(12)),
      color: AlpineColors.background3b,
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            var sourceOrigin = ref.read(sourceOriginProvider);
            var destinationOrigin = ref.read(destinationOriginProvider);
            var converter = ref.read(converterProvider);
            return Column(
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: AlpineButton(
                            onTap: () => setState(() => converter.generateDefaultConversions(
                                  source: sourceOrigin.getSchema(),
                                  destination: destinationOrigin.schema,
                                )),
                            label: "Add Default Conversions",
                            color: AlpineColors.buttonColor2,
                            isFilled: true,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        AlpineButton(
                          onTap: () => setState(() {
                            converter.schemaConversions.add(ConvertSchemaMap(connections: []));
                          }),
                          label: "Add Conversion",
                          color: AlpineColors.buttonColor2,
                          isFilled: true,
                          fontSize: 14,
                        ),
                      ],
                    )),
                // ElevatedButton(
                //   onPressed: () => setState(() => converter.generateDefaultConversions(
                //         source: sourceOrigin.schema,
                //         destination: destinationOrigin.schema,
                //       )),
                //   child: const Text("Generate Default Conversions"),
                // ),
                ...converter.schemaConversions
                    .map((m) => ConvertSchemaMapWidget(
                          convertSchemaMap: m,
                          onDelete: () => setState(
                            () => converter.schemaConversions.removeWhere((el) => el.hashCode == m.hashCode),
                          ),
                        ))
                    .toList()
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDestinationColumn() {
    return Container(
      width: 100,
      height: double.infinity,
      // color: Colors.grey[700],
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            var sourceOrigin = ref.read(sourceOriginProvider);
            var destinationOrigin = ref.watch(destinationOriginProvider);
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: const Text(
                    "Appwrite",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: AlpineButton(
                    onTap: () => toPopUp(
                      context,
                      Routes.appwriteConfigDialog,
                      AppwriteConfigDialogData(destinationOrigin),
                    ),
                    label: "Configure",
                    color: AlpineColors.buttonColor2,
                    isFilled: true,
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () => toPopUp(
                //     context,
                //     Routes.appwriteConfigDialog,
                //     AppwriteConfigDialogData(destinationOrigin),
                //   ),
                //   child: const Text("Go to Appwrite Interface"),
                // ),
                // const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: AlpineButton(
                    onTap: () => setState(() => destinationOrigin.addSchemaFromSchema(sourceOrigin.getSchema())),
                    label: "Add from Source",
                    color: AlpineColors.buttonColor2,
                    isFilled: true,
                    fontSize: 14,
                    // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () => setState(() => destinationOrigin.addSchemaFromSchema(sourceOrigin.schema)),
                //   child: const Text("Generate Appwrite Schema based on Source Schema"),
                // ),
                ...destinationOrigin.schema
                    .map((m) => SchemaMapWidget(
                          schemaMap: m,
                          forOrigin: Origin.destination,
                        ))
                    .toList()
              ],
            );
          },
        ),
      ),
    );
  }

  Future<bool> _handleConversionConfirmations(List<ConfirmationData> confirmations) async {
    bool cancelConversion = false;
    for (int i = 0; i < confirmations.length; i++) {
      await showDialog(
          context: context,
          builder: (_) => Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return ConversionConfirmationDialog(
                  confirmationData: confirmations[i],
                  confirmationNumber: i + 1,
                  totalConfirmations: confirmations.length,
                  onCancel: () => cancelConversion = true,
                );
              }));
      if (cancelConversion) {
        print("canceling conversion");
        return false;
      }
    }

    return true;
  }
}
