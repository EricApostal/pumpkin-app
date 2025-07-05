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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final logsAsyncValue = ref.watch(serverLogsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Console"),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              ref.read(serverLogsProvider.notifier).clearLogs();
            },
            tooltip: "Clear logs",
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: padding.bottom + 100),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.surface,
                      ),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await ref
                            .read(serverControllerProvider.notifier)
                            .start();
                      },
                      child: const Text("Start Server"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      _scrollToBottom();
                    },
                    child: const Icon(Icons.arrow_downward),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  // border: Border.all(color: Colors.grey.shade300),
                ),
                child: logsAsyncValue.when(
                  data: (logs) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return logs.isEmpty
                        ? const Center(
                            child: Text(
                              "No logs yet. Start the server to see logs.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(24),
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),
                                child: SelectableText(
                                  log,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: _getLogColor(log),
                                  ),
                                ),
                              );
                            },
                          );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading logs: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLogColor(String log) {
    if (log.toLowerCase().contains('error')) {
      return Colors.red.shade300;
    } else if (log.toLowerCase().contains('warning')) {
      return Colors.orange.shade300;
    } else if (log.toLowerCase().contains('starting')) {
      return Colors.green.shade300;
    } else {
      return Colors.grey.shade300;
    }
  }
}
