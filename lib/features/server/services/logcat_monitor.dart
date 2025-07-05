import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// A service that monitors logcat output in a separate isolate (Android only)
class LogcatMonitor {
  static LogcatMonitor? _instance;
  static LogcatMonitor get instance => _instance ??= LogcatMonitor._();

  LogcatMonitor._();

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  StreamController<String>? _logController;

  /// Stream of logcat messages
  Stream<String> get logStream =>
      _logController?.stream ?? const Stream.empty();

  /// Start monitoring logcat with the given options
  Future<bool> startMonitor(String options) async {
    // Only works on Android
    if (!Platform.isAndroid) {
      print(
        'LogcatMonitor: Not running on Android, logcat monitoring disabled',
      );
      return false;
    }

    if (_isolate != null) {
      await stopMonitor();
    }

    try {
      _receivePort = ReceivePort();
      _logController = StreamController<String>.broadcast();

      // Listen to messages from the isolate
      _receivePort!.listen((message) {
        if (message is String) {
          _logController?.add(message);
        } else if (message is SendPort) {
          _sendPort = message;
        }
      });

      // Start the isolate
      _isolate = await Isolate.spawn(
        _logcatIsolateEntry,
        _LogcatIsolateData(sendPort: _receivePort!.sendPort, options: options),
      );

      return true;
    } catch (e) {
      print('Error starting logcat monitor: $e');
      return false;
    }
  }

  /// Stop monitoring logcat
  Future<void> stopMonitor() async {
    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }

    if (_sendPort != null) {
      _sendPort!.send('stop');
      _sendPort = null;
    }

    _receivePort?.close();
    _receivePort = null;

    await _logController?.close();
    _logController = null;
  }

  /// Run a one-time logcat command and return the output
  Future<String> runLogcat(String options) async {
    if (!Platform.isAndroid) {
      return 'LogcatMonitor: Not available on this platform';
    }

    try {
      final result = await Process.run('logcat', options.split(' '));
      return result.stdout.toString();
    } catch (e) {
      return 'EXCEPTION: $e';
    }
  }
}

/// Data structure for passing information to the isolate
class _LogcatIsolateData {
  final SendPort sendPort;
  final String options;

  _LogcatIsolateData({required this.sendPort, required this.options});
}

/// Entry point for the logcat monitoring isolate
void _logcatIsolateEntry(_LogcatIsolateData data) async {
  // Only works on Android
  if (!Platform.isAndroid) {
    data.sendPort.send('LogcatMonitor: Not running on Android');
    return;
  }

  final receivePort = ReceivePort();
  Process? logcatProcess;

  // Send our receive port back to the main isolate
  data.sendPort.send(receivePort.sendPort);

  // Listen for stop commands
  receivePort.listen((message) {
    if (message == 'stop') {
      logcatProcess?.kill();
      receivePort.close();
    }
  });

  try {
    // Start the logcat process
    final args = data.options.isEmpty ? <String>[] : data.options.split(' ');
    logcatProcess = await Process.start('logcat', args);

    // Listen to stdout
    logcatProcess.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            // Add small delay to prevent overwhelming the main thread
            Future.delayed(const Duration(milliseconds: 10), () {
              data.sendPort.send(line);
            });
          },
          onError: (error) {
            data.sendPort.send('EXCEPTION: $error');
          },
          onDone: () {
            data.sendPort.send('logcatMonitor completed');
          },
        );

    // Listen to stderr
    logcatProcess.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          data.sendPort.send('STDERR: $line');
        });

    // Wait for the process to complete
    final exitCode = await logcatProcess.exitCode;
    data.sendPort.send('logcat process exited with code: $exitCode');
  } catch (e) {
    data.sendPort.send('EXCEPTION: $e');
  } finally {
    receivePort.close();
  }
}
