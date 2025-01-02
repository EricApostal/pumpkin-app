import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pumpkin_app/features/config/controllers/config.dart';
import 'package:pumpkin_app/theme/theme.dart';
import 'package:toml/toml.dart';

final configDisplayNames = {
  'server_address': 'Server Address',
  'seed': 'World Seed',
  'max_players': 'Maximum Players',
  'view_distance': 'View Distance',
  'simulation_distance': 'Simulation Distance',
  'default_difficulty': 'Default Difficulty',
  'op_permission_level': 'Operator Permission Level',
  'allow_nether': 'Allow Nether',
  'hardcore': 'Hardcore Mode',
  'online_mode': 'Online Mode',
  'encryption': 'Enable Encryption',
  'motd': 'Server Message',
  'tps': 'Ticks Per Second',
  'default_gamemode': 'Default Game Mode',
  'scrub_ips': 'Scrub IP Addresses',
  'use_favicon': 'Use Server Icon',
  'favicon_path': 'Server Icon Path',
};

enum ConfigInputType {
  text,
  number,
  slider,
  toggle,
  dropdown,
}

final configMetadata = {
  'server_address': ConfigInputType.text,
  'seed': ConfigInputType.text,
  'max_players': ConfigInputType.number,
  'view_distance': ConfigInputType.slider,
  'simulation_distance': ConfigInputType.slider,
  'default_difficulty': ConfigInputType.dropdown,
  'op_permission_level': ConfigInputType.number,
  'allow_nether': ConfigInputType.toggle,
  'hardcore': ConfigInputType.toggle,
  'online_mode': ConfigInputType.toggle,
  'encryption': ConfigInputType.toggle,
  'motd': ConfigInputType.text,
  'tps': ConfigInputType.number,
  'default_gamemode': ConfigInputType.dropdown,
  'scrub_ips': ConfigInputType.toggle,
  'use_favicon': ConfigInputType.toggle,
  'favicon_path': ConfigInputType.text,
};

class ConfigEditorView extends ConsumerStatefulWidget {
  const ConfigEditorView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConfigEditorViewState();
}

class _ConfigEditorViewState extends ConsumerState<ConfigEditorView> {
  // Map to store the current values of all config fields
  final Map<String, dynamic> currentValues = {};

  @override
  Widget build(BuildContext context) {
    TomlDocument? config = ref.watch(configProvider).valueOrNull;

    if (config == null) {
      return const Center(child: CircularProgressIndicator());
    }
    var configMap = config.toMap();

    return Scaffold(
      backgroundColor: Theme.of(context).custom.colorTheme.foreground,
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        itemCount: configMap.length,
        itemBuilder: (context, index) {
          String key = configMap.keys.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ConfigCard(
              configKey: key,
              configValue: configMap[key].toString(),
              displayName: configDisplayNames[key] ?? key,
              inputType: configMetadata[key] ?? ConfigInputType.text,
              onValueChanged: (value) {
                currentValues[key] = value;
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveConfig(context, configMap),
        backgroundColor: Theme.of(context).custom.colorTheme.primary,
        child: const Icon(Icons.save),
      ),
    );
  }

  void _saveConfig(BuildContext context, Map<String, dynamic> configMap) {
    // Merge current values with original config
    final updatedConfig = Map<String, dynamic>.from(configMap);
    updatedConfig.addAll(currentValues);

    // Save the updated config
    ref.read(configProvider.notifier).save(updatedConfig);

    // Show save confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class ConfigCard extends ConsumerStatefulWidget {
  final String configKey;
  final String configValue;
  final String displayName;
  final ConfigInputType inputType;
  final Function(dynamic) onValueChanged;

  const ConfigCard({
    super.key,
    required this.configKey,
    required this.configValue,
    required this.displayName,
    required this.inputType,
    required this.onValueChanged,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConfigCardState();
}

class _ConfigCardState extends ConsumerState<ConfigCard> {
  late dynamic currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = parseInitialValue();
    // Initialize the parent's currentValues map with the initial value
    widget.onValueChanged(currentValue);
  }

  dynamic parseInitialValue() {
    switch (widget.inputType) {
      case ConfigInputType.number:
        return double.tryParse(widget.configValue)?.toInt() ?? 0;
      case ConfigInputType.toggle:
        return widget.configValue.toLowerCase() == 'true';
      case ConfigInputType.slider:
        return double.tryParse(widget.configValue)?.toInt() ?? 0;
      default:
        return widget.configValue;
    }
  }

  Widget buildInput() {
    switch (widget.inputType) {
      case ConfigInputType.text:
        return TextFormField(
          initialValue: currentValue.toString(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).custom.colorTheme.primary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).custom.colorTheme.foreground,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() => currentValue = value);
            widget.onValueChanged(value);
          },
        );

      case ConfigInputType.number:
        return TextFormField(
          initialValue: currentValue.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).custom.colorTheme.primary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).custom.colorTheme.foreground,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            final numValue =
                double.tryParse(value)?.toInt() ?? currentValue.toInt();
            setState(() => currentValue = numValue);
            widget.onValueChanged(numValue);
          },
        );

      case ConfigInputType.slider:
        return Column(
          children: [
            SliderTheme(
              data: SliderThemeData(
                thumbColor: Theme.of(context).custom.colorTheme.primary,
                activeTrackColor: Theme.of(context).custom.colorTheme.primary,
                inactiveTrackColor:
                    Theme.of(context).custom.colorTheme.background,
                activeTickMarkColor:
                    Theme.of(context).custom.colorTheme.primary,
                overlayColor: Theme.of(context)
                    .custom
                    .colorTheme
                    .primary
                    .withOpacity(0.3),
                valueIndicatorColor:
                    Theme.of(context).custom.colorTheme.primary,
                valueIndicatorTextStyle: GoogleFonts.publicSans(
                  color: Theme.of(context).custom.colorTheme.dirtywhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Slider(
                value: currentValue.toDouble(),
                min: widget.configKey == 'view_distance' ? 2 : 0,
                max: widget.configKey == 'view_distance' ? 32 : 20,
                divisions: widget.configKey == 'view_distance' ? 30 : 20,
                label: currentValue.round().toString(),
                onChanged: (value) {
                  setState(() => currentValue = value);
                  widget.onValueChanged(value);
                },
              ),
            ),
            Text(currentValue.round().toString()),
          ],
        );

      case ConfigInputType.toggle:
        return Switch(
          activeColor: Theme.of(context).custom.colorTheme.primary,
          value: currentValue,
          onChanged: (value) {
            setState(() => currentValue = value);
            widget.onValueChanged(value);
          },
        );

      case ConfigInputType.dropdown:
        List<String> options = _getOptionsForKey(widget.configKey);
        return DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => currentValue = value);
            widget.onValueChanged(value);
          },
        );

      default:
        return Text(currentValue.toString());
    }
  }

  List<String> _getOptionsForKey(String key) {
    switch (key) {
      case 'default_difficulty':
        return ['Peaceful', 'Easy', 'Normal', 'Hard'];
      case 'default_gamemode':
        return ['Survival', 'Creative', 'Adventure', 'Spectator'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.displayName,
              style: GoogleFonts.publicSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).custom.colorTheme.dirtywhite,
              ),
            ),
            const SizedBox(height: 12),
            buildInput(),
          ],
        ),
      ),
    );
  }
}
