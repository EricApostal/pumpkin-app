import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pumpkin_app/features/features/controllers/features.dart';
import 'package:pumpkin_app/theme/theme.dart';
import 'package:toml/toml.dart';

final featureDisplayNames = {
  'proxy.enabled': 'Enable Proxy',
  'proxy.velocity.enabled': 'Enable Velocity Proxy',
  'proxy.velocity.secret': 'Velocity Secret',
  'proxy.bungeecord.enabled': 'Enable BungeeCord',
  'authentication.enabled': 'Enable Authentication',
  'authentication.prevent_proxy_connections': 'Prevent Proxy Connections',
  'authentication.player_profile.allow_banned_players': 'Allow Banned Players',
  'authentication.player_profile.allowed_actions': 'Allowed Profile Actions',
  'authentication.textures.enabled': 'Enable Textures',
  'authentication.textures.allowed_url_schemes': 'Allowed URL Schemes',
  'authentication.textures.allowed_url_domains': 'Allowed URL Domains',
  'authentication.textures.types.skin': 'Allow Skin Textures',
  'authentication.textures.types.cape': 'Allow Cape Textures',
  'authentication.textures.types.elytra': 'Allow Elytra Textures',
  'packet_compression.enabled': 'Enable Packet Compression',
  'packet_compression.threshold': 'Compression Threshold',
  'packet_compression.level': 'Compression Level',
  'resource_pack.enabled': 'Enable Resource Pack',
  'resource_pack.resource_pack_url': 'Resource Pack URL',
  'resource_pack.resource_pack_sha1': 'Resource Pack SHA1',
  'resource_pack.prompt_message': 'Resource Pack Prompt Message',
  'resource_pack.force': 'Force Resource Pack',
  'commands.use_console': 'Enable Console Commands',
  'commands.log_console': 'Log Console Commands',
  'commands.default_op_level': 'Default Operator Level',
  'rcon.enabled': 'Enable RCON',
  'rcon.address': 'RCON Address',
  'rcon.password': 'RCON Password',
  'rcon.max_connections': 'RCON Max Connections',
  'rcon.logging.log_logged_successfully': 'Log Successful RCON Logins',
  'rcon.logging.log_wrong_password': 'Log Failed RCON Logins',
  'rcon.logging.log_commands': 'Log RCON Commands',
  'rcon.logging.log_quit': 'Log RCON Disconnections',
  'pvp.enabled': 'Enable PvP',
  'pvp.hurt_animation': 'Show Hurt Animation',
  'pvp.protect_creative': 'Protect Creative Mode Players',
  'pvp.knockback': 'Enable Knockback',
  'pvp.swing': 'Show Swing Animation',
  'logging.enabled': 'Enable Logging',
  'logging.level': 'Log Level',
  'logging.env': 'Log Environment',
  'logging.threads': 'Log Threads',
  'logging.color': 'Colored Logs',
  'logging.timestamp': 'Show Timestamps',
  'query.enabled': 'Enable Query',
  'server_links.enabled': 'Enable Server Links',
  'server_links.bug_report': 'Bug Report URL',
  'server_links.support': 'Support URL',
  'server_links.status': 'Status Page URL',
  'server_links.feedback': 'Feedback URL',
  'server_links.community': 'Community URL',
  'server_links.website': 'Website URL',
  'server_links.forums': 'Forums URL',
  'server_links.news': 'News URL',
  'server_links.announcements': 'Announcements URL',
  'lan_broadcast.enabled': 'Enable LAN Broadcast',
};

enum FeatureInputType {
  text,
  number,
  toggle,
  dropdown,
  list,
}

final featureInputTypes = {
  'proxy.enabled': FeatureInputType.toggle,
  'proxy.velocity.enabled': FeatureInputType.toggle,
  'proxy.velocity.secret': FeatureInputType.text,
  'proxy.bungeecord.enabled': FeatureInputType.toggle,
  'authentication.enabled': FeatureInputType.toggle,
  'authentication.prevent_proxy_connections': FeatureInputType.toggle,
  'authentication.player_profile.allow_banned_players': FeatureInputType.toggle,
  'authentication.player_profile.allowed_actions': FeatureInputType.list,
  'authentication.textures.enabled': FeatureInputType.toggle,
  'authentication.textures.allowed_url_schemes': FeatureInputType.list,
  'authentication.textures.allowed_url_domains': FeatureInputType.list,
  'authentication.textures.types.skin': FeatureInputType.toggle,
  'authentication.textures.types.cape': FeatureInputType.toggle,
  'authentication.textures.types.elytra': FeatureInputType.toggle,
  'packet_compression.enabled': FeatureInputType.toggle,
  'packet_compression.threshold': FeatureInputType.number,
  'packet_compression.level': FeatureInputType.number,
  'resource_pack.enabled': FeatureInputType.toggle,
  'resource_pack.resource_pack_url': FeatureInputType.text,
  'resource_pack.resource_pack_sha1': FeatureInputType.text,
  'resource_pack.prompt_message': FeatureInputType.text,
  'resource_pack.force': FeatureInputType.toggle,
  'commands.use_console': FeatureInputType.toggle,
  'commands.log_console': FeatureInputType.toggle,
  'commands.default_op_level': FeatureInputType.number,
  'rcon.enabled': FeatureInputType.toggle,
  'rcon.address': FeatureInputType.text,
  'rcon.password': FeatureInputType.text,
  'rcon.max_connections': FeatureInputType.number,
  'rcon.logging.log_logged_successfully': FeatureInputType.toggle,
  'rcon.logging.log_wrong_password': FeatureInputType.toggle,
  'rcon.logging.log_commands': FeatureInputType.toggle,
  'rcon.logging.log_quit': FeatureInputType.toggle,
  'pvp.enabled': FeatureInputType.toggle,
  'pvp.hurt_animation': FeatureInputType.toggle,
  'pvp.protect_creative': FeatureInputType.toggle,
  'pvp.knockback': FeatureInputType.toggle,
  'pvp.swing': FeatureInputType.toggle,
  'logging.enabled': FeatureInputType.toggle,
  'logging.level': FeatureInputType.dropdown,
  'logging.env': FeatureInputType.toggle,
  'logging.threads': FeatureInputType.toggle,
  'logging.color': FeatureInputType.toggle,
  'logging.timestamp': FeatureInputType.toggle,
  'query.enabled': FeatureInputType.toggle,
  'server_links.enabled': FeatureInputType.toggle,
  'server_links.bug_report': FeatureInputType.text,
  'server_links.support': FeatureInputType.text,
  'server_links.status': FeatureInputType.text,
  'server_links.feedback': FeatureInputType.text,
  'server_links.community': FeatureInputType.text,
  'server_links.website': FeatureInputType.text,
  'server_links.forums': FeatureInputType.text,
  'server_links.news': FeatureInputType.text,
  'server_links.announcements': FeatureInputType.text,
  'lan_broadcast.enabled': FeatureInputType.toggle,
};

final featureGroups = {
  'Proxy Settings': ['proxy'],
  'Authentication': ['authentication'],
  'Packet Compression': ['packet_compression'],
  'Resource Pack': ['resource_pack'],
  'Commands': ['commands'],
  'RCON': ['rcon'],
  'PvP': ['pvp'],
  'Logging': ['logging'],
  'Query': ['query'],
  'Server Links': ['server_links'],
  'LAN': ['lan_broadcast'],
};

class FeaturesEditorView extends ConsumerStatefulWidget {
  const FeaturesEditorView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FeaturesEditorViewState();
}

class _FeaturesEditorViewState extends ConsumerState<FeaturesEditorView> {
  final Map<String, dynamic> currentValues = {};
  void _saveFeatures(Map<String, dynamic> flatConfig) {
    final updatedConfig = Map<String, dynamic>.from(flatConfig);
    updatedConfig.addAll(currentValues);

    final nestedConfig = unflattenToml(updatedConfig);
    ref.read(featuresProvider.notifier).save(nestedConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Features configuration saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Widget> buildGroupSection(String groupTitle, List<String> groupPrefixes,
      Map<String, dynamic> flatConfig) {
    final List<Widget> widgets = [];
    final relevantSettings = flatConfig.entries
        .where((entry) =>
            groupPrefixes.any((prefix) => entry.key.startsWith(prefix)))
        .toList();

    if (relevantSettings.isEmpty) return [];

    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          groupTitle,
          style: GoogleFonts.publicSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).custom.colorTheme.dirtywhite,
          ),
        ),
      ),
    );

    for (var entry in relevantSettings) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: FeatureCard(
            configKey: entry.key,
            configValue: entry.value.toString(),
            displayName: featureDisplayNames[entry.key] ?? entry.key,
            inputType: featureInputTypes[entry.key] ?? FeatureInputType.text,
            onValueChanged: (value) {
              currentValues[entry.key] = value;
            },
          ),
        ),
      );
    }

    return widgets;
  }

  Map<String, dynamic> flattenToml(Map<String, dynamic> toml,
      [String prefix = '']) {
    final result = <String, dynamic>{};

    toml.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        result.addAll(flattenToml(value, newKey));
      } else {
        result[newKey] = value;
      }
    });

    return result;
  }

  Map<String, dynamic> unflattenToml(Map<String, dynamic> flat) {
    final result = <String, dynamic>{};

    flat.forEach((key, value) {
      final parts = key.split('.');
      var current = result;

      for (var i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i == parts.length - 1) {
          current[part] = value;
        } else {
          current[part] = current[part] ?? <String, dynamic>{};
          current = current[part] as Map<String, dynamic>;
        }
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    TomlDocument? features = ref.watch(featuresProvider).valueOrNull;

    if (features == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final flatConfig = flattenToml(features.toMap());

    return Scaffold(
      backgroundColor: Theme.of(context).custom.colorTheme.foreground,
      body: ListView(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        children: featureGroups.entries
            .expand((group) =>
                buildGroupSection(group.key, group.value, flatConfig))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveFeatures(flatConfig),
        backgroundColor: Theme.of(context).custom.colorTheme.primary,
        child: const Icon(Icons.save),
      ),
    );
  }
}

// Keep the existing FeatureCard class unchanged...

class FeatureCard extends StatefulWidget {
  final String configKey;
  final String configValue;
  final String displayName;
  final FeatureInputType inputType;
  final Function(dynamic) onValueChanged;

  const FeatureCard({
    super.key,
    required this.configKey,
    required this.configValue,
    required this.displayName,
    required this.inputType,
    required this.onValueChanged,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  late dynamic currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = parseInitialValue();
    widget.onValueChanged(currentValue);
  }

  dynamic parseInitialValue() {
    switch (widget.inputType) {
      case FeatureInputType.number:
        return double.tryParse(widget.configValue)?.toInt() ?? 0;
      case FeatureInputType.toggle:
        return widget.configValue.toLowerCase() == 'true';
      case FeatureInputType.list:
        if (widget.configValue.startsWith('[') &&
            widget.configValue.endsWith(']')) {
          final listStr =
              widget.configValue.substring(1, widget.configValue.length - 1);
          return listStr
              .split(',')
              .map((e) => e.trim().replaceAll('"', ''))
              .toList();
        }
        return [];
      default:
        return widget.configValue;
    }
  }

  Widget buildInput() {
    switch (widget.inputType) {
      case FeatureInputType.text:
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

      case FeatureInputType.number:
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

      case FeatureInputType.toggle:
        return Switch(
          activeColor: Theme.of(context).custom.colorTheme.primary,
          value: currentValue,
          onChanged: (value) {
            setState(() => currentValue = value);
            widget.onValueChanged(value);
          },
        );

      case FeatureInputType.dropdown:
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
            if (value != null) {
              setState(() => currentValue = value);
              widget.onValueChanged(value);
            }
          },
        );

      case FeatureInputType.list:
        return Column(
          children: [
            ...currentValue.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: value.toString(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (newValue) {
                          final newList = List<String>.from(currentValue);
                          newList[index] = newValue;
                          setState(() => currentValue = newList);
                          widget.onValueChanged(newList);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        final newList = List<String>.from(currentValue)
                          ..removeAt(index);
                        setState(() => currentValue = newList);
                        widget.onValueChanged(newList);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              onPressed: () {
                final newList = List<String>.from(currentValue)..add('');
                setState(() => currentValue = newList);
                widget.onValueChanged(newList);
              },
            ),
          ],
        );

      default:
        return Text(currentValue.toString());
    }
  }

  List<String> _getOptionsForKey(String key) {
    switch (key) {
      case 'logging.level':
        return ['Debug', 'Info', 'Warn', 'Error'];
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
