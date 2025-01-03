import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/config/config/configuration.dart';
import 'package:pumpkin_app/features/config/controllers/config.dart';
import 'package:pumpkin_app/features/config/views/base_config.dart';

class ServerConfigEditorView extends ConsumerWidget {
  const ServerConfigEditorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configState = ref.watch(configProvider);

    return BaseConfigView(
      configDocument: configState,
      settingsGroups: serverSettingsGroups,
      dropdownOptions: serverDropdownOptions,
      onSave: (newConfig) {
        ref.read(configProvider.notifier).save(newConfig);
      },
      emptyStateMessage:
          "No configuration file found. The server may need to be started first.",
    );
  }
}
