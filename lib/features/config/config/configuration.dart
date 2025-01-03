import 'package:flutter/material.dart';
import 'package:pumpkin_app/features/config/models/config.dart';

final serverSettingsGroups = [
  SettingsGroup(
    title: 'Server Network',
    description: 'Network and connection settings',
    icon: Icons.router,
    settings: [
      ConfigSetting(
        key: 'server_address',
        displayName: 'Server Address',
        inputType: ConfigInputType.text,
        defaultValue: 'localhost',
        description: 'The address the server will listen on',
      ),
      ConfigSetting(
        key: 'online_mode',
        displayName: 'Online Mode',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
        description: 'Enable player authentication with Minecraft servers',
      ),
      ConfigSetting(
        key: 'max_players',
        displayName: 'Maximum Players',
        inputType: ConfigInputType.number,
        defaultValue: 20,
        constraints: {'min': 1, 'max': 1000},
        description: 'Maximum number of concurrent players',
      ),
      ConfigSetting(
        key: 'encryption',
        displayName: 'Enable Encryption',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
    ],
  ),
  SettingsGroup(
    title: 'Game Rules',
    description: 'Basic gameplay settings',
    icon: Icons.games,
    settings: [
      ConfigSetting(
        key: 'default_gamemode',
        displayName: 'Default Game Mode',
        inputType: ConfigInputType.dropdown,
        defaultValue: 'survival',
        description: 'Starting game mode for new players',
      ),
      ConfigSetting(
        key: 'default_difficulty',
        displayName: 'Default Difficulty',
        inputType: ConfigInputType.dropdown,
        defaultValue: 'normal',
        description: 'Server difficulty level',
      ),
      ConfigSetting(
        key: 'hardcore',
        displayName: 'Hardcore Mode',
        inputType: ConfigInputType.toggle,
        defaultValue: false,
        description: 'Permanent death and maximum difficulty',
      ),
      ConfigSetting(
        key: 'allow_nether',
        displayName: 'Allow Nether',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
        description: 'Enable access to the Nether dimension',
      ),
    ],
  ),
  SettingsGroup(
    title: 'World Settings',
    description: 'World generation and rendering',
    icon: Icons.public,
    settings: [
      ConfigSetting(
        key: 'seed',
        displayName: 'World Seed',
        inputType: ConfigInputType.text,
        description: 'Seed for world generation (leave empty for random)',
      ),
      ConfigSetting(
        key: 'view_distance',
        displayName: 'View Distance',
        inputType: ConfigInputType.slider,
        defaultValue: 10,
        constraints: {'min': 2, 'max': 32, 'divisions': 30},
        description: 'Maximum chunk render distance',
      ),
      ConfigSetting(
        key: 'simulation_distance',
        displayName: 'Simulation Distance',
        inputType: ConfigInputType.slider,
        defaultValue: 10,
        constraints: {'min': 2, 'max': 32, 'divisions': 30},
        description: 'Maximum chunk simulation distance',
      ),
    ],
  ),
  SettingsGroup(
    title: 'Server Identity',
    description: 'Server appearance and branding',
    icon: Icons.branding_watermark,
    settings: [
      ConfigSetting(
        key: 'motd',
        displayName: 'Server Message',
        inputType: ConfigInputType.text,
        defaultValue: 'A Minecraft Server',
        description: 'Message shown in the server list',
      ),
      ConfigSetting(
        key: 'use_favicon',
        displayName: 'Use Server Icon',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
        description: 'Show custom server icon in the server list',
      ),
      ConfigSetting(
        key: 'favicon_path',
        displayName: 'Server Icon Path',
        inputType: ConfigInputType.text,
        description: 'Path to the server icon file (PNG format)',
      ),
    ],
  ),
  SettingsGroup(
    title: 'Performance',
    description: 'Server performance settings',
    icon: Icons.speed,
    settings: [
      ConfigSetting(
        key: 'tps',
        displayName: 'Ticks Per Second',
        inputType: ConfigInputType.number,
        defaultValue: 20,
        constraints: {'min': 1, 'max': 100},
        description: 'Server tick rate (default: 20)',
      ),
    ],
  ),
  SettingsGroup(
    title: 'Security',
    description: 'Security and privacy settings',
    icon: Icons.security,
    settings: [
      ConfigSetting(
        key: 'op_permission_level',
        displayName: 'Operator Permission Level',
        inputType: ConfigInputType.number,
        defaultValue: 4,
        constraints: {'min': 1, 'max': 4},
        description: 'Default permission level for operators',
      ),
      ConfigSetting(
        key: 'scrub_ips',
        displayName: 'Scrub IP Addresses',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
        description: 'Remove IP addresses from log files',
      ),
    ],
  ),
];

final serverDropdownOptions = {
  'default_difficulty': ['Peaceful', 'Easy', 'Normal', 'Hard'],
  'default_gamemode': ['Survival', 'Creative', 'Adventure', 'Spectator'],
};
