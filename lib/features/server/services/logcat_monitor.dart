import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// Monitors logcat output in a separate isolate for Android
class LogcatMonitor {
  static LogcatMonitor? _instance;
  static LogcatMonitor get instance => _instance ??= LogcatMonitor._();

  LogcatMonitor._();

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  StreamController<String>? _logController;

  Stream<String> get logStream =>
      _logController?.stream ?? const Stream.empty();

  Future<bool> startMonitor(String options) async {
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

      _receivePort!.listen((message) {
        if (message is String) {
          _logController?.add(message);
        } else if (message is SendPort) {
          _sendPort = message;
        }
      });

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

class _LogcatIsolateData {
  final SendPort sendPort;
  final String options;

  _LogcatIsolateData({required this.sendPort, required this.options});
}

void _logcatIsolateEntry(_LogcatIsolateData data) async {
  if (!Platform.isAndroid) {
    data.sendPort.send('LogcatMonitor: Not running on Android');
    return;
  }

  final receivePort = ReceivePort();
  Process? logcatProcess;

  data.sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message == 'stop') {
      logcatProcess?.kill();
      receivePort.close();
    }
  });

  try {
    final args = data.options.isEmpty ? <String>[] : data.options.split(' ');
    logcatProcess = await Process.start('logcat', args);

    logcatProcess.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
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

    logcatProcess.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          data.sendPort.send('STDERR: $line');
        });

    final exitCode = await logcatProcess.exitCode;
    data.sendPort.send('logcat process exited with code: $exitCode');
  } catch (e) {
    data.sendPort.send('EXCEPTION: $e');
  } finally {
    receivePort.close();
  }
}
