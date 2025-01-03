import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/config/config/features.dart';
import 'package:pumpkin_app/features/config/controllers/features.dart';
import 'package:pumpkin_app/features/config/views/base_config.dart';

class FeaturesView extends ConsumerWidget {
  const FeaturesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuresState = ref.watch(featuresProvider);

    return BaseConfigView(
      configDocument: featuresState,
      settingsGroups: featureSettingsGroups,
      onSave: (newConfig) {
        ref.read(featuresProvider.notifier).save(newConfig);
      },
      emptyStateMessage:
          "No features configuration found. The server may need to be started first.",
    );
  }
}
