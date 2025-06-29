import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              HapticFeedback.lightImpact();
              print("starting server!");
              final appDirectory = await getApplicationDocumentsDirectory();
              final path = "${appDirectory.path}/server";
              final directory = await Directory(path).create();
              print("Items = ${directory.listSync()}");

              // await startServer(appDir: path);
            },
            child: Text("Start Server"),
          ),
        ),
      ),
    );
  }
}
