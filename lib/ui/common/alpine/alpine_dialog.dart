import 'package:data_migrator/ui/common/alpine/alpine_close_button.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

abstract class AlpineDialog extends StatefulWidget {
  const AlpineDialog({Key? key}) : super(key: key);

  @override
  AlpineDialogState createState();
}

abstract class AlpineDialogState extends State<AlpineDialog> with TickerProviderStateMixin {
  final double width;
  late TabController tabController;
  final bool showHeaderDivider;

  AlpineDialogState({
    this.width = 600,
    this.showHeaderDivider = true,
  });

  void removeDialog() {
    if (context.vRouter.historyCanBack() && context.vRouter.previousUrl != null) {
      var url = context.vRouter.previousUrl!;
      context.vRouter.historyBack();
      context.vRouter.to(url, isReplacement: true);
    }
  }

  @override
  void initState() {
    int tabCount = buildTabs().length;
    if (tabCount > 0) {
      tabController = TabController(length: tabCount, vsync: this)
        ..addListener(() {
          setState(() {});
        });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      backgroundColor: AlpineColors.background1b,
      child: SizedBox(
        width: width,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(left: 40, top: 35, bottom: 0, right: 40),
                    child: AlpineCloseButton(onTap: () => Navigator.pop(context)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildTabs(),
                      if (showHeaderDivider) Divider(color: AlpineColors.chartLineColor2, thickness: 2),
                      buildBody(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildTabs() => [];
  Widget _buildTabs() {
    var tabs = buildTabs();
    if (tabs.isEmpty) return const SizedBox();
    return TabBar(
      controller: tabController,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      indicatorColor: AlpineColors.textColor1,
      tabs: tabs,
    );
  }

  List<Widget> buildHeader();
  Widget _buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 40, top: 35, bottom: 30, right: 40),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buildHeader(),
      ),
    );
  }

  Widget buildBody();

  List<Widget> buildFooter();
  Widget _buildFooter() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AlpineColors.background2a,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      ),
      padding: const EdgeInsets.only(top: 25, left: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildFooter(),
      ),
    );
  }
}
