import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/server/controllers/server.dart';

class ConsoleScreen extends ConsumerStatefulWidget {
  const ConsoleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConsoleScreenState();
}

class _ConsoleScreenState extends ConsumerState<ConsoleScreen> {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      appBar: AppBar(title: Text("Console")),
      body: Padding(
        padding: EdgeInsets.only(bottom: padding.bottom + 90),
        child: Column(
          children: [
            Container(
              child: Padding(padding: EdgeInsets.all(12), child: Text("yoo")),
            ),
            Expanded(
              child: Center(
                child: OutlinedButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await ref.read(serverControllerProvider.notifier).start();
                  },
                  child: Text("start"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
