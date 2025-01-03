import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pumpkin_app/features/config/components/settings_card.dart';
import 'package:pumpkin_app/features/config/models/config.dart';
import 'package:pumpkin_app/features/config/services/config.dart';
import 'package:pumpkin_app/theme/theme.dart';
import 'package:toml/toml.dart';

class BaseConfigView extends ConsumerStatefulWidget {
  final AsyncValue<TomlDocument?> configDocument;
  final List<SettingsGroup> settingsGroups;
  final Map<String, List<String>>? dropdownOptions;
  final Function(Map<String, dynamic>) onSave;
  final String? emptyStateMessage;
  final bool useGroupHeaders;

  const BaseConfigView({
    super.key,
    required this.configDocument,
    required this.settingsGroups,
    required this.onSave,
    this.dropdownOptions,
    this.emptyStateMessage,
    this.useGroupHeaders = true,
  });

  @override
  ConsumerState<BaseConfigView> createState() => _BaseConfigViewState();
}

class _BaseConfigViewState extends ConsumerState<BaseConfigView> {
  final Map<String, dynamic> currentValues = {};
  final ScrollController _scrollController = ScrollController();
  Timer? _saveDebouncer;

  void _handleValueChange(
      String key, dynamic value, Map<String, dynamic> configMap) {
    currentValues[key] = value;

    _saveDebouncer?.cancel();

    // Schedule a new save operation
    _saveDebouncer = Timer(const Duration(milliseconds: 500), () {
      final updatedConfig = Map<String, dynamic>.from(configMap);
      updatedConfig.addAll(currentValues);
      widget.onSave(updatedConfig);
    });
  }

  Widget _buildGroupHeader(SettingsGroup group) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          if (group.icon != null) ...[
            Icon(
              group.icon,
              color: Theme.of(context).custom.colorTheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: GoogleFonts.publicSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).custom.colorTheme.dirtywhite,
                  ),
                ),
                if (group.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    group.description!,
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      color: Theme.of(context)
                          .custom
                          .colorTheme
                          .dirtywhite
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(
      SettingsGroup group, Map<String, dynamic> configMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.useGroupHeaders) _buildGroupHeader(group),
        ...group.settings
            .map((setting) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: SettingCard(
                    setting: setting,
                    currentValue: configMap[setting.key]?.toString() ??
                        setting.defaultValue?.toString() ??
                        '',
                    onValueChanged: (value) => _handleValueChange(
                      setting.key,
                      value,
                      configMap,
                    ),
                    dropdownOptions: widget.dropdownOptions,
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 48,
              color: Theme.of(context)
                  .custom
                  .colorTheme
                  .dirtywhite
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              widget.emptyStateMessage ??
                  "No configuration file found. The server may need to be started first.",
              style: GoogleFonts.publicSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).custom.colorTheme.dirtywhite,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.configDocument.when(
      data: (config) {
        if (config == null) {
          return _buildEmptyState();
        }

        final configMap = ConfigService.flattenConfig(config.toMap());

        return Scrollbar(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: 16.0,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            children: widget.settingsGroups
                .map((group) => _buildSettingsGroup(group, configMap))
                .toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading configuration: $error',
          style: GoogleFonts.publicSans(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveDebouncer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
