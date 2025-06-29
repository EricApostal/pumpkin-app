import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/navigator/views/navigation_scope.dart';
import 'package:pumpkin_app/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(ProviderScope(child: const PumpkinApp()));
}

class PumpkinApp extends StatelessWidget {
  const PumpkinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seedColor = Color.fromARGB(255, 43, 102, 191);

    return MaterialApp(
      themeMode: ThemeMode.dark,

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(),
        useMaterial3: true,
      ),

      home: NavigationScope(child: Center(child: Text("balls"))),
    );
  }
}
