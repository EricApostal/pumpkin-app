// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serverLogsHash() => r'3f135ed311a35b773233b62069a28e7c9da12781';

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
String _$serverControllerHash() => r'5ae41bf0bba591d591ed61d84842da42c790b84b';

/// See also [ServerController].
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
