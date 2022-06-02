import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WindowBorder(
        color: AlpineColors.background1a,
        width: 1,
        child: Stack(
          children: [
            ProviderScope(
      child: VRouter(
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
    ),
            Container(
                height: 30,
                child: Row(
                  children: const [LeftSide(), RightSide()],
                ),
              
            ),
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

const sidebarColor = Colors.transparent;// Color(0xFFF6A00C);

class LeftSide extends StatelessWidget {
  const LeftSide({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        child: Container(
            color: sidebarColor,
            child: Column(
              children: [
                WindowTitleBarBox(child: MoveWindow()),
                Expanded(child: Container())
              ],
            )));
  }
}

const backgroundStartColor = Colors.transparent;// Color(0xFFFFD500);
const backgroundEndColor = Colors.transparent;//Color(0xFFF6A00C);

class RightSide extends StatelessWidget {
  const RightSide({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundStartColor, backgroundEndColor],
              stops: [0.0, 1.0]),
        ),
        child: Column(children: [
          WindowTitleBarBox(
            child: Row(
              children: [Expanded(child: MoveWindow()), const WindowButtons()],
            ),
          )
        ]),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: AlpineColors.buttonColor2,
    mouseOver: AlpineColors.buttonColor2.withOpacity(0.5),
    mouseDown: AlpineColors.buttonColor2,
    iconMouseOver: Colors.black,
    iconMouseDown: Colors.black,
);

final closeButtonColors = WindowButtonColors(
    mouseOver:AlpineColors.buttonColor2.withOpacity(0.5),
    mouseDown:AlpineColors.buttonColor2,
    iconNormal: AlpineColors.buttonColor2,
    iconMouseOver: Colors.black,
    iconMouseDown: Colors.black,
);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}