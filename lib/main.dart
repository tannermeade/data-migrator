import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/platform_window/window.dart';
import 'package:data_migrator/ui/common/platform_window/windows_titlebar.dart';
import 'package:data_migrator/ui/lines.dart';
import 'package:data_migrator/ui/common/values/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import 'ui/dialog_handler.dart';
import 'ui/home.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "DataMigrator";
    appWindow.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ProviderScope(
        child: Stack(
          children: [
            VRouter(
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.dark,
              darkTheme: ThemeData.dark().copyWith(scaffoldBackgroundColor: AlpineColors.background1a),
              theme: ThemeData.light().copyWith(scaffoldBackgroundColor: AlpineColors.background1a),
              mode: VRouterMode.history,
              navigatorKey: navigatorKey,
              //navigatorKey: GlobalKey(debugLabel: "VRouter:app"),
              afterEnter: (context, __, ___) {
                /// Sync the UI with the url: we show the popup if [showPopUp] has been set
                if (context.vRouter.historyState.containsKey('showPopUp')) {
                  showPopUp(context: navigatorKey.currentContext!);
                }
              },
              transitionDuration: const Duration(milliseconds: 0),
              buildTransition: (animation, _, child) => FadeTransition(
                opacity: animation,
                child: child,
              ),

              routes: [
                VWidget(path: '', widget: DebugWidget(const Text("/"), Routes.home)),
                VWidget(
                  path: Routes.home,
                  widget: const MyHomePage(title: 'this is a title'),
                ),
                VWidget(
                  path: Routes.linesExample,
                  widget: const LinesExample(),
                ),
              ],
            ),
            const WindowsTitleBar(),
          ],
        ),
      ),
    );
  }
}

class DebugWidget extends StatelessWidget {
  DebugWidget([
    this.text,
    this.routeName,
  ]);

  final Widget? text;
  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        text ?? const Text("default text"),
        if (routeName != null)
          TextButton(
            onPressed: () => context.vRouter.to(routeName!, isReplacement: false),
            child: Text("routeButton: $routeName"),
          ),
      ],
    )));
  }
}
