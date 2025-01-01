import 'dart:io';

enum ServerStatus {
  stopped,
  starting,
  running,
  error,
}

class ServerState {
  final Process? process;
  final ServerStatus status;
  final String? error;

  ServerState({
    this.process,
    this.status = ServerStatus.stopped,
    this.error,
  });

  ServerState copyWith({
    Process? process,
    ServerStatus? status,
    String? error,
  }) {
    return ServerState(
      process: process ?? this.process,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
