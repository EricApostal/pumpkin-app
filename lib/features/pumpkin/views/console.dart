import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/pumpkin/components/command_bar.dart';
import 'package:pumpkin_app/features/pumpkin/components/console.dart';
import 'package:pumpkin_app/features/pumpkin/components/controls.dart';

class ConsoleView extends ConsumerStatefulWidget {
  const ConsoleView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends ConsumerState<ConsoleView> {
  CommandBarController commandBarController = CommandBarController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.of(context).padding.top,
        12,
        MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          Expanded(child: Console()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ControlBar(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ));
  }
}
