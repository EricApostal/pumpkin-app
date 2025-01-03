import 'package:flutter/material.dart';
import 'package:pumpkin_app/features/config/models/config.dart';

final featureSettingsGroups = [
  SettingsGroup(
    title: 'Proxy Settings',
    description: 'Configure proxy and connection handling',
    icon: Icons.swap_horiz,
    settings: [
      ConfigSetting(
        key: 'proxy.enabled',
        displayName: 'Enable Proxy',
        inputType: ConfigInputType.toggle,
        defaultValue: false,
        description: 'Enable proxy support for the server',
      ),
      ConfigSetting(
        key: 'proxy.velocity.enabled',
        displayName: 'Enable Velocity Proxy',
        inputType: ConfigInputType.toggle,
        defaultValue: false,
      ),
      ConfigSetting(
        key: 'proxy.velocity.secret',
        displayName: 'Velocity Secret',
        inputType: ConfigInputType.text,
        description: 'Secret key for Velocity authentication',
      ),
      ConfigSetting(
        key: 'proxy.bungeecord.enabled',
        displayName: 'Enable BungeeCord',
        inputType: ConfigInputType.toggle,
        defaultValue: false,
      ),
    ],
  ),
  SettingsGroup(
    title: 'Authentication',
    description: 'Player authentication and profile settings',
    icon: Icons.security,
    settings: [
      ConfigSetting(
        key: 'authentication.enabled',
        displayName: 'Enable Authentication',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'authentication.prevent_proxy_connections',
        displayName: 'Prevent Proxy Connections',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'authentication.player_profile.allow_banned_players',
        displayName: 'Allow Banned Players',
        inputType: ConfigInputType.toggle,
        defaultValue: false,
      ),
      ConfigSetting(
        key: 'authentication.player_profile.allowed_actions',
        displayName: 'Allowed Profile Actions',
        inputType: ConfigInputType.list,
        defaultValue: ['login', 'register'],
      ),
    ],
  ),
  SettingsGroup(
    title: 'Player Textures',
    description: 'Configure player skin and texture settings',
    icon: Icons.person_outline,
    settings: [
      ConfigSetting(
        key: 'authentication.textures.enabled',
        displayName: 'Enable Textures',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'authentication.textures.allowed_url_schemes',
        displayName: 'Allowed URL Schemes',
        inputType: ConfigInputType.list,
        defaultValue: ['http', 'https'],
      ),
      ConfigSetting(
        key: 'authentication.textures.allowed_url_domains',
        displayName: 'Allowed URL Domains',
        inputType: ConfigInputType.list,
        defaultValue: ['textures.minecraft.net'],
      ),
      ConfigSetting(
        key: 'authentication.textures.types.skin',
        displayName: 'Allow Skin Textures',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'authentication.textures.types.cape',
        displayName: 'Allow Cape Textures',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'authentication.textures.types.elytra',
        displayName: 'Allow Elytra Textures',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
    ],
  ),
  SettingsGroup(
    title: 'Packet Handling',
    description: 'Network packet configuration',
    icon: Icons.settings_ethernet,
    settings: [
      ConfigSetting(
        key: 'packet_compression.enabled',
        displayName: 'Enable Packet Compression',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'packet_compression.threshold',
        displayName: 'Compression Threshold',
        inputType: ConfigInputType.number,
        defaultValue: 256,
        constraints: {'min': 64, 'max': 1024},
      ),
      ConfigSetting(
        key: 'packet_compression.level',
        displayName: 'Compression Level',
        inputType: ConfigInputType.slider,
        defaultValue: 6,
        constraints: {'min': 1, 'max': 9, 'divisions': 8},
      ),
    ],
  ),
  SettingsGroup(
    title: 'Resource Pack',
    description: 'Server resource pack configuration',
    icon: Icons.folder_zip,
    settings: [
      ConfigSetting(
        key: 'resource_pack.enabled',
        displayName: 'Enable Resource Pack',
        inputType: ConfigInputType.toggle,
        defaultValue: false,
      ),
      ConfigSetting(
        key: 'resource_pack.resource_pack_url',
        displayName: 'Resource Pack URL',
        inputType: ConfigInputType.text,
      ),
      ConfigSetting(
        key: 'resource_pack.resource_pack_sha1',
        displayName: 'Resource Pack SHA1',
        inputType: ConfigInputType.text,
      ),
      ConfigSetting(
        key: 'resource_pack.prompt_message',
        displayName: 'Resource Pack Prompt Message',
        inputType: ConfigInputType.text,
        defaultValue: 'Please accept the resource pack',
      ),
      ConfigSetting(
        key: 'resource_pack.force',
        displayName: 'Force Resource Pack',
        inputType: ConfigInputType.toggle,
        defaultValue: false,
      ),
    ],
  ),
  SettingsGroup(
    title: 'Commands',
    description: 'Server command configuration',
    icon: Icons.terminal,
    settings: [
      ConfigSetting(
        key: 'commands.use_console',
        displayName: 'Enable Console Commands',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'commands.log_console',
        displayName: 'Log Console Commands',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'commands.default_op_level',
        displayName: 'Default Operator Level',
        inputType: ConfigInputType.number,
        defaultValue: 4,
        constraints: {'min': 1, 'max': 4},
      ),
    ],
  ),
  SettingsGroup(
    title: 'RCON',
    description: 'Remote console configuration',
    icon: Icons.computer,
    settings: [
      ConfigSetting(
        key: 'rcon.enabled',
        displayName: 'Enable RCON',
        inputType: ConfigInputType.toggle,
        defaultValue: false,
      ),
      ConfigSetting(
        key: 'rcon.password',
        displayName: 'RCON Password',
        inputType: ConfigInputType.text,
      ),
      ConfigSetting(
        key: 'rcon.port',
        displayName: 'RCON Port',
        inputType: ConfigInputType.number,
        defaultValue: 25575,
        constraints: {'min': 1024, 'max': 65535},
      ),
      ConfigSetting(
        key: 'rcon.max_connections',
        displayName: 'RCON Max Connections',
        inputType: ConfigInputType.number,
        defaultValue: 1,
        constraints: {'min': 1, 'max': 100},
      ),
    ],
  ),
  SettingsGroup(
    title: 'Combat Settings',
    description: 'PvP and combat configuration',
    icon: Icons.gavel,
    settings: [
      ConfigSetting(
        key: 'pvp.enabled',
        displayName: 'Enable PvP',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'pvp.hurt_animation',
        displayName: 'Show Hurt Animation',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'pvp.protect_creative',
        displayName: 'Protect Creative Mode Players',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
      ConfigSetting(
        key: 'pvp.knockback',
        displayName: 'Enable Knockback',
        inputType: ConfigInputType.toggle,
        defaultValue: true,
      ),
    ],
  ),
];
