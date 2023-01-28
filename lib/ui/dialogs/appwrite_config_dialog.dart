import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/appwrite_origin.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:data_migrator/ui/common/alpine/alpine_button.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/alpine/alpine_close_button.dart';
import 'package:data_migrator/ui/common/values/enums.dart';
import 'package:data_migrator/ui/common/widgets/selectable_widget.dart';
import 'package:data_migrator/ui/common/widgets/schema_map_widget.dart';
import 'package:data_migrator/ui/dialog_handler.dart';
import 'package:data_migrator/ui/common/values/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:console_flutter_sdk/models.dart' as aw;

class AppwriteConfigDialogData extends DialogData {
  AppwriteConfigDialogData(this.dataOrigin);
  final AppwriteOrigin dataOrigin;
  // final String content;
  // final Function() onDelete;
}

class AppwriteConfigDialog extends StatefulWidget {
  const AppwriteConfigDialog({
    Key? key,
    required this.data,
  }) : super(key: key);

  final AppwriteConfigDialogData data;

  @override
  State<AppwriteConfigDialog> createState() => _AppwriteConfigDialogState();
}

class _AppwriteConfigDialogState extends State<AppwriteConfigDialog> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _endpointController;
  late TextEditingController _apiKeyController;
  late TextEditingController _bundleSizeController;

  bool _isLoggingIn = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _endpointController = TextEditingController(text: "");
    _apiKeyController = TextEditingController(text: widget.data.dataOrigin.currentAPIKey);
    _bundleSizeController = TextEditingController(text: widget.data.dataOrigin.config.bundleByteSize.toString());

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
          const Text(
            "Appwrite Configuration",
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
    return Consumer(builder: (context, ref, child) {
      var appwriteOrigin = ref.read(destinationOriginProvider);
      return Container(
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!appwriteOrigin.isAuthenticated) ..._buildLogin(appwriteOrigin),
              if (appwriteOrigin.isAuthenticated && !_isLoggingIn) ..._buildProjects(appwriteOrigin),
              if (appwriteOrigin.isAuthenticated && !_isLoggingIn && appwriteOrigin.selectedProject != null)
                ..._buildDatabases(appwriteOrigin),
              if (appwriteOrigin.isAuthenticated && appwriteOrigin.selectedProject != null)
                ..._buildApiKey(appwriteOrigin),
              if (appwriteOrigin.isAuthenticated && !_isLoggingIn) _buildBundleSize(appwriteOrigin),
              if (appwriteOrigin.isAuthenticated &&
                  appwriteOrigin.selectedProject != null &&
                  appwriteOrigin.selectedDatabase != null)
                ..._importCollections(appwriteOrigin),
              const SizedBox(height: 10),
              if (appwriteOrigin.isAuthenticated) _buildBottomBar(appwriteOrigin),
            ],
          ));
    });
  }

  List<Widget> _buildLogin(AppwriteOrigin appwriteOrigin) {
    return [
      Text(
        "Endpoint",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 16,
          fontWeight: FontWeight.w200,
        ),
      ),
      const SizedBox(height: 15),
      TextField(
        controller: _endpointController,
        cursorColor: Colors.black,
        cursorWidth: 1,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          fillColor: AlpineColors.textColor1,
          filled: true,
          focusColor: AlpineColors.textColor1,
          hoverColor: AlpineColors.textColor1,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        "Email",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 16,
          fontWeight: FontWeight.w200,
        ),
      ),
      const SizedBox(height: 15),
      TextField(
        controller: _emailController,
        cursorColor: Colors.black,
        cursorWidth: 1,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          fillColor: AlpineColors.textColor1,
          filled: true,
          focusColor: AlpineColors.textColor1,
          hoverColor: AlpineColors.textColor1,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        "Password",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 16,
          fontWeight: FontWeight.w200,
        ),
      ),
      const SizedBox(height: 15),
      TextField(
        controller: _passwordController,
        obscureText: true,
        cursorColor: Colors.black,
        cursorWidth: 1,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          fillColor: AlpineColors.textColor1,
          filled: true,
          focusColor: AlpineColors.textColor1,
          hoverColor: AlpineColors.textColor1,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      const SizedBox(height: 20),
      _isLoggingIn
          ? const CircularProgressIndicator.adaptive()
          : AlpineButton(
              label: "Login",
              width: 100,
              // textColor: Colors.white,
              color: AlpineColors.buttonColor2,
              isFilled: true,
              onTap: () async {
                setState(() => _isLoggingIn = true);
                var result = await appwriteOrigin.authenticate(
                  email: _emailController.text,
                  password: _passwordController.text,
                  endpoint: _endpointController.text,
                );
                print(result);
                setState(() => _isLoggingIn = false);
              },
            ),
      const SizedBox(height: 50),
    ];
  }

  List<Widget> _buildProjects(AppwriteOrigin appwriteOrigin) {
    return [
      const Text(
        "Select Project",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w200,
        ),
      ),
      if (appwriteOrigin.selectedProject != null)
        SelectableWidget(
          // project: appwriteOrigin.selectedProject!,
          onTap: () {},
          name: appwriteOrigin.selectedProject!.name,
          selected: appwriteOrigin.selectedProject != null &&
              appwriteOrigin.selectedProject!.$id == appwriteOrigin.selectedProject!.$id,
        ),
      if (appwriteOrigin.selectedProject == null)
        FutureBuilder<aw.ProjectList>(
          future: appwriteOrigin.getProjects(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Column(
                  children: snapshot.data!.projects
                      .map((p) => SelectableWidget(
                            onTap: () async {
                              await appwriteOrigin.selectProject(p);
                              setState(() {});
                            },
                            name: p.name,
                            selected: false,
                          ))
                      .toList());
            }
            return Row(
              children: const [CircularProgressIndicator.adaptive(), SizedBox(width: 10), Text("loading projects")],
            );
          },
        ),
      const SizedBox(height: 10),
    ];
  }

  List<Widget> _buildDatabases(AppwriteOrigin appwriteOrigin) {
    return [
      const Text(
        "Select Database",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w200,
        ),
      ),
      if (appwriteOrigin.selectedDatabase != null)
        SelectableWidget(
          onTap: () {},
          name: appwriteOrigin.selectedDatabase!.name,
          selected: appwriteOrigin.selectedDatabase != null &&
              appwriteOrigin.selectedDatabase!.$id == appwriteOrigin.selectedDatabase!.$id,
        ),
      if (appwriteOrigin.selectedDatabase == null)
        FutureBuilder<aw.DatabaseList>(
          future: appwriteOrigin.getDatabases(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Column(
                  children: snapshot.data!.databases
                      .map((db) => SelectableWidget(
                            name: db.name,
                            selected: false,
                            onTap: () {
                              appwriteOrigin.selectDatabase(db);
                              setState(() {});
                            },
                          ))
                      .toList());
            }
            if (appwriteOrigin.selectedProject == null) {
              return Row(
                children: [
                  Text(
                    "Select a project first",
                    style: TextStyle(
                      color: AlpineColors.textColor1,
                      fontSize: 12,
                      fontWeight: FontWeight.w200,
                    ),
                  )
                ],
              );
            }
            return Row(
              children: const [CircularProgressIndicator.adaptive(), SizedBox(width: 10), Text("loading databases")],
            );
          },
        ),
      const SizedBox(height: 10),
    ];
  }

  Widget _buildBottomBar(AppwriteOrigin appwriteOrigin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AlpineButton(
          label: "Logout",
          width: 100,
          textColor: Colors.white,
          color: AlpineColors.warningColor,
          isFilled: true,
          onTap: () async {
            setState(() => _isLoggingIn = true);
            var result = await appwriteOrigin.logout();
            setState(() => _isLoggingIn = false);
          },
        )
      ],
    );
  }

  List<Widget> _importCollections(AppwriteOrigin appwriteOrigin) {
    return [
      const Text(
        "Import Collections",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w200,
        ),
      ),
      FutureBuilder<List<SchemaMap>>(
        future: appwriteOrigin.getRemoteSchema(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.isEmpty) {
              return Text(
                "No collections to import.",
                style: TextStyle(
                  color: AlpineColors.textColor1,
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                ),
              );
            }
            return Column(
                children: snapshot.data!
                    .map((s) => SchemaMapWidget(
                          schemaMap: s,
                          forOrigin: Origin.destination,
                          icon: const Tooltip(
                            message: "Add to Migration",
                            child: Icon(
                              Icons.add,
                              color: Colors.grey,
                            ),
                          ),
                          onEdit: () {
                            appwriteOrigin.schema.add(s);
                          },
                        ))
                    .toList());
          }
          return const Text("loading projects");
        },
      )
    ];
  }

  List<Widget> _buildApiKey(AppwriteOrigin appwriteOrigin) {
    return [
      Text(
        "Appwrite API Key",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 16,
          fontWeight: FontWeight.w200,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        "This is needed to create the cloud function that is used to insert the data. The API key should have "
        "the read and write permission scopes for the following: users, teams, collections, attributes, indexes, "
        "documents, files, functions, and execution.",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 12,
          fontWeight: FontWeight.w200,
        ),
      ),
      const SizedBox(height: 15),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _apiKeyController,
              cursorColor: Colors.black,
              cursorWidth: 1,
              style: const TextStyle(color: Colors.black),
              // obscureText: true,
              decoration: InputDecoration(
                hintText: "api key",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                fillColor: AlpineColors.textColor1,
                filled: true,
                focusColor: AlpineColors.textColor1,
                hoverColor: AlpineColors.textColor1,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          AlpineButton(
            label: "Save",
            color: AlpineColors.buttonColor2,
            isFilled: true,
            onTap: () async {
              widget.data.dataOrigin.apiKey = _apiKeyController.text;
              // await widget.data.dataOrigin.deleteAllFiles();
            },
          ),
        ],
      ),
      const SizedBox(height: 25),
    ];
  }

  Widget _buildBundleSize(AppwriteOrigin appwriteOrigin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Bundle Size ",
                  style: TextStyle(
                    color: AlpineColors.textColor1,
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                TextSpan(
                  text: "(in MB)",
                  style: TextStyle(
                    color: AlpineColors.textColor1,
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: _bundleSizeController,
              cursorColor: Colors.black,
              cursorWidth: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                fillColor: AlpineColors.textColor1,
                filled: true,
                focusColor: AlpineColors.textColor1,
                hoverColor: AlpineColors.textColor1,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          AlpineButton(
            label: "Save",
            color: AlpineColors.buttonColor2,
            isFilled: true,
            onTap: () async {
              widget.data.dataOrigin.config.bundleByteSize = int.parse(_bundleSizeController.text);
              // await widget.data.dataOrigin.deleteAllFiles();
            },
          ),
        ],
      ),
    );
  }
}
