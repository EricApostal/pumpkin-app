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
        colorScheme: ColorScheme.dark(),
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
  Process? process;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 12,
            right: 12,
          ),
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
                  process = await Process.start(
                    executablePath,
                    [],
                    workingDirectory: applicationDirectory.path,
                  );
                  process!.stdout.transform(utf8.decoder).listen((data) {
                    setState(() {
                      outputText += data;
                    });
                  });
                  process!.stderr.transform(utf8.decoder).listen((data) {
                    setState(() {
                      outputText += data;
                    });
                  });
                },
                child: const Text('Run Executable'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(child: Text(outputText)),
                ),
              ),
              // text box
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Run Command',
                ),
                onSubmitted: (value) {
                  print("submitted: $value");
                  process?.stdin.writeln(value);
                },
                onEditingComplete: () {
                  print("editing complete");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
