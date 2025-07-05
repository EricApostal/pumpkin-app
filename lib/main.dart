import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/navigator/controller/router.dart';
import 'package:pumpkin_app/rust/src/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(ProviderScope(child: const PumpkinApp()));
}

class PumpkinApp extends StatelessWidget {
  const PumpkinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seedColor = Color.fromARGB(255, 255, 141, 11);

    return MaterialApp.router(
      themeMode: ThemeMode.dark,
      routerConfig: routerController,

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(),
        useMaterial3: true,
      ),
    );
  }
}
