import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pumpkin_app/src/rust/api/simple.dart';
import 'package:pumpkin_app/src/rust/frb_generated.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  print("RUNNING MAIN!!!");
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
              print("starting server!");
              final appDirectory = await getApplicationDocumentsDirectory();
              print("Items = ${appDirectory.listSync()}");

              final directory = await Directory(appDirectory.path).create();

              await startServer(appDir: directory.path);
            },
            child: Text("Start Server"),
          ),
        ),
      ),
    );
  }
}
