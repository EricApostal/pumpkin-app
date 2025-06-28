import 'package:flutter/material.dart';
import 'package:pumpkin_app/src/rust/api/simple.dart';
import 'package:pumpkin_app/src/rust/frb_generated.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: OutlinedButton(
            onPressed: () async {
              final appDirectory = await getApplicationDocumentsDirectory();
              final path = "${appDirectory.path}/server";
              await startServer(appDir: path);
            },
            child: Text("Start Server"),
          ),
        ),
      ),
    );
  }
}
