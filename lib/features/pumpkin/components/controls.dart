import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/pumpkin/components/command_bar.dart';
import 'package:pumpkin_app/features/pumpkin/components/control_button.dart';
import 'package:pumpkin_app/features/pumpkin/controllers/server.dart';
import 'package:pumpkin_app/features/pumpkin/models/server.dart';
import 'package:pumpkin_app/theme/theme.dart';

class ControlBar extends ConsumerStatefulWidget {
  const ControlBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ControlBarState();
}

class _ControlBarState extends ConsumerState<ControlBar> {
  CommandBarController commandBarController = CommandBarController();
  @override
  Widget build(BuildContext context) {
    ServerState? serverInfo = ref.watch(serverControllerProvider).valueOrNull;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: ControlButton(
                        label: "Start",
                        color: Theme.of(context).custom.colorTheme.primary,
                        onPressed: () {
                          ref
                              .read(serverControllerProvider.notifier)
                              .startServer();
                        })),
                const SizedBox(width: 8),
                Expanded(
                    child: ControlButton(
                        label: "Stop",
                        color: Theme.of(context).custom.colorTheme.red,
                        onPressed: () {
                          ref
                              .read(serverControllerProvider.notifier)
                              .stopServer();
                        })),
                const SizedBox(width: 8),
                Expanded(
                    child: ControlButton(
                        label: "Restart",
                        color: Theme.of(context).custom.colorTheme.background,
                        onPressed: () {
                          ref
                              .read(serverControllerProvider.notifier)
                              .restartServer();
                        })),
              ],
            ),
            SizedBox(height: 20),
            CommandBar(controller: commandBarController)
          ],
        ),
      ),
    );
  }
}
