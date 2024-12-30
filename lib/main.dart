import 'package:flutter/material.dart';
import 'package:pumpkin_app/src/rust/api/simple.dart';
import 'package:pumpkin_app/src/rust/frb_generated.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Pumpkin MC Manager')),
        body: const ServerManagerScreen(),
      ),
    );
  }
}

class ServerManagerScreen extends StatefulWidget {
  const ServerManagerScreen({super.key});

  @override
  State<ServerManagerScreen> createState() => _ServerManagerScreenState();
}

class _ServerManagerScreenState extends State<ServerManagerScreen> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await Permission.storage.request();
    if (await Permission.storage.request().isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          print("button pressed, calling run pumpkin");
          runPumpkin();
        },
        child: Text('Send a Signal from Dart to Rust'),
      ),
    );
  }
}
