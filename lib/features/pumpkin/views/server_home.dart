import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pumpkin_app/features/config/controllers/config.dart';
import 'package:pumpkin_app/features/config/models/config.dart';
import 'package:pumpkin_app/features/config/views/base_config.dart';
import 'package:pumpkin_app/features/config/views/configuration_editor.dart';
import 'package:pumpkin_app/features/console/components/command_bar.dart';
import 'package:pumpkin_app/features/console/components/ip_info_bar.dart';
import 'package:pumpkin_app/features/console/views/console.dart';
import 'package:pumpkin_app/features/console/components/controls.dart';
import 'package:pumpkin_app/features/config/views/feature_editor.dart';
import 'package:pumpkin_app/features/pumpkin/components/header.dart';
import 'package:pumpkin_app/shared/utils/platform.dart';
import 'package:pumpkin_app/theme/theme.dart';
import 'package:tab_container/tab_container.dart';

class ConsoleView extends ConsumerStatefulWidget {
  const ConsoleView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConsoleViewState();
}

class ScopedBody extends StatelessWidget {
  final Widget child;
  const ScopedBody({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isSmartwatch(context)) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 8),
        child: child,
      );
    }
    return child;
  }
}

class _ConsoleViewState extends ConsumerState<ConsoleView> {
  CommandBarController commandBarController = CommandBarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScopedBody(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            MediaQuery.of(context).padding.top,
            12,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ServerHeader(serverName: "Pumpkin Server"),
              ),
              const SizedBox(height: 8),
              ServerTabs(),
            ],
          ),
        ),
      ),
    );
  }
}

class ServerTabs extends ConsumerStatefulWidget {
  const ServerTabs({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServerTabsState();
}

class _ServerTabsState extends ConsumerState<ServerTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget _buildConsoleTab(bool isKeyboardVisible) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: Console(),
              ),
              if (!isKeyboardVisible) const SizedBox(height: 8),
              if (!isKeyboardVisible) const IpInfoBar(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ControlBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible =
        KeyboardVisibilityProvider.isKeyboardVisible(context);
    final configState = ref.watch(configProvider);

    return TabContainer(
      controller: _tabController,
      tabEdge: TabEdge.top,
      tabsStart: 0.1,
      tabsEnd: 0.9,
      tabMaxLength: 100,
      borderRadius: BorderRadius.circular(24),
      tabBorderRadius: BorderRadius.circular(10),
      childPadding: const EdgeInsets.all(0),
      selectedTextStyle: GoogleFonts.publicSans(
        color: Theme.of(context).custom.colorTheme.dirtywhite,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      unselectedTextStyle: GoogleFonts.publicSans(
        color: Theme.of(context).custom.colorTheme.dirtywhite,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      colors: [
        Theme.of(context).custom.colorTheme.foreground,
        Theme.of(context).custom.colorTheme.foreground,
        Theme.of(context).custom.colorTheme.foreground,
      ],
      tabs: const [
        Text('Console'),
        Text('Config'),
        Text('Features'),
      ],
      children: [
        _buildConsoleTab(isKeyboardVisible),
        ServerConfigEditorView(),
        FeaturesView(),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
