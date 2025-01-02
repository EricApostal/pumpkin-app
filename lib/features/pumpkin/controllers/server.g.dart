// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serverLogsHash() => r'5a03740ad935a5de7c55b35b27c579bc902de1b0';

/// See also [serverLogs].
@ProviderFor(serverLogs)
final serverLogsProvider = StreamProvider<String>.internal(
  serverLogs,
  name: r'serverLogsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$serverLogsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServerLogsRef = StreamProviderRef<String>;
String _$serverControllerHash() => r'aed012df33b643546a1ba9538a06212dad48c016';

/// A controller that manages the lifecycle of a server process.
/// Ensures only one server instance can run at a time and provides
/// robust error handling and state management.
///
/// Copied from [ServerController].
@ProviderFor(ServerController)
final serverControllerProvider =
    AsyncNotifierProvider<ServerController, ServerState>.internal(
  ServerController.new,
  name: r'serverControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serverControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ServerController = AsyncNotifier<ServerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
