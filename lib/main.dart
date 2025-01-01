import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String outputText = '';
  static const platform = MethodChannel('app_channel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () async {
                final String nativeLibDir =
                    await platform.invokeMethod('getNativeLibDir');
                final applicationDirectory =
                    await getApplicationDocumentsDirectory();

                print("Native Library Directory: $nativeLibDir");
                final executablePath = '$nativeLibDir/libpumpkin.so';
                final result = await Process.run(executablePath, [],
                    stdoutEncoding: utf8,
                    stderrEncoding: utf8,
                    workingDirectory: applicationDirectory.path);
                print("Result: ${result.stdout}");
              },
              child: const Text('Run Executable'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(outputText),
            ),
          ],
        ),
      ),
    );
  }
}
