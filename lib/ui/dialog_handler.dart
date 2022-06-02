import 'dart:convert';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/appwrite_origin.dart';
import 'package:data_migrator/infastructure/data_origins/csv_origin/csv_origin.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:data_migrator/ui/dialogs/appwrite_config_dialog.dart';
import 'package:data_migrator/ui/dialogs/csv_config_dialog.dart';
import 'package:data_migrator/ui/common/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

import 'common/values/enums.dart';
import 'dialogs/edit_schema_map_dialog.dart';

// DialogData? _dialogData;
List<PopupIndex> _popupStack = [];

class DialogData {}

class PopupIndex {
  PopupIndex(this.route, [this.data]);
  final String route;
  final DialogData? data;
}

/// Navigate to a new page with the same url but with [showPopUp] in the
/// history state
///
///
/// [showPopUp] in the history state will cause [VRouter.afterEnter] to
/// display the popup
void toPopUp(BuildContext context, String dialogRoute, [DialogData? arguments]) {
  if (_popupStack.isEmpty) {
    _popupStack.add(PopupIndex(dialogRoute, arguments));
    print("[${_popupStack.length}]. added popup stack:" + _popupStack.last.route);
    context.vRouter.to(context.vRouter.url, historyState: {
      'showPopUp': dialogRoute,
    });
  } else {
    _popupStack.add(PopupIndex(dialogRoute, arguments));
    print("[${_popupStack.length}] added popup stack:" + _popupStack.last.route);
    showPopUp(context: context);
  }
}

/// Show the popup
///
///
/// Also handles the popup closing with [popUpClosed]
Future<void> showPopUp({required BuildContext context}) async {
  // String dialogRoute = context.vRouter.historyState["showPopUp"] ?? Routes.unknownDialog;
  if (_popupStack.isNotEmpty) {
    print("[${_popupStack.length}] showing popup on stack:" + _popupStack.last.route);
    var dialog = _getDialog(_popupStack.last);

    // Show the popup
    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => dialog,
    );

    // Handle popup closing
    popUpClosed(context);
  }
}

/// Sync the browser with the UI if needed
void popUpClosed(BuildContext context) {
  // Wait for the next frame so that [context.vRouter.historyState] gets a chance to be updated
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // If it contains the key, it means that it was dismissed manually (NOT with browser back/forward button)
    if (context.vRouter.historyState.containsKey('showPopUp')) {
      if (context.vRouter.historyCanBack()) {
        if (_popupStack.length == 1) {
          // We go back to the url entry where there was no popup, does not work if a popup can create a popup
          context.vRouter.historyBack();
        }
      } else {
        // If the popup was created on the first page, we can't go back so we choose to go forward
        context.vRouter.to(context.vRouter.url);
      }
      print("[${_popupStack.length - 1}] removing popup stack:" + _popupStack.last.route);
      _popupStack.removeLast();
    } else {
      _popupStack = [];
    }
  });
}

Widget _getDialog(PopupIndex popupIndex) {
  if (popupIndex.route == Routes.editSchemaMapDialog) {
    EditSchemaMapDialogData data = popupIndex.data is EditSchemaMapDialogData && popupIndex.data != null
        ? popupIndex.data! as EditSchemaMapDialogData
        : EditSchemaMapDialogData(SchemaMap(name: '[name] no schema map...'), Origin.destination);
    return EditSchemaMapDialog(data: data);
  } else if (popupIndex.route == Routes.csvConfigDialog) {
    CsvConfigDialogData data = popupIndex.data is CsvConfigDialogData && popupIndex.data != null
        ? popupIndex.data! as CsvConfigDialogData
        : CsvConfigDialogData(SchemaMap(name: '[name] no schema map...'));
    return CsvConfigDialog(data: data);
  } else if (popupIndex.route == Routes.appwriteConfigDialog) {
    AppwriteConfigDialogData data = popupIndex.data is AppwriteConfigDialogData && popupIndex.data != null
        ? popupIndex.data! as AppwriteConfigDialogData
        : AppwriteConfigDialogData(AppwriteOrigin());
    return AppwriteConfigDialog(data: data);
  }
  // else if (popupIndex.route == Routes.appwriteImportSchemaDialog) {
  //   AppwriteImportSchemaDialogData data = popupIndex.data is AppwriteImportSchemaDialogData && popupIndex.data != null
  //       ? popupIndex.data! as AppwriteImportSchemaDialogData
  //       : AppwriteImportSchemaDialogData(SchemaMap(name: '[name] no schema map...'));
  //   return AppwriteImportSchemaDialog(data: data);
  // }

  return CsvConfigDialog(data: CsvConfigDialogData(SchemaMap(name: '[name] no schema map...')));
}
