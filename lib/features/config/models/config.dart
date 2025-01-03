import 'package:flutter/material.dart';

enum ConfigInputType { text, number, slider, toggle, dropdown, list }

class ConfigSetting {
  final String key;
  final String displayName;
  final ConfigInputType inputType;
  final dynamic defaultValue;
  final Map<String, dynamic>? constraints;
  final String? description;

  const ConfigSetting({
    required this.key,
    required this.displayName,
    required this.inputType,
    this.defaultValue,
    this.constraints,
    this.description,
  });
}

class SettingsGroup {
  final String title;
  final String? description;
  final List<ConfigSetting> settings;
  final IconData? icon;

  const SettingsGroup({
    required this.title,
    required this.settings,
    this.description,
    this.icon,
  });
}
