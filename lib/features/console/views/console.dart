import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pumpkin_app/features/pumpkin/controllers/server.dart';
import 'package:pumpkin_app/features/pumpkin/models/server.dart';
import 'package:pumpkin_app/theme/theme.dart';

final consoleLogsProvider = StateProvider<Set<String>>((ref) => {});

class Console extends ConsumerStatefulWidget {
  const Console({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConsoleState();
}

class _ConsoleState extends ConsumerState<Console> {
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _setupLogListeners();
  }

  void _setupLogListeners() {
    ref.listenManual(serverLogsProvider, (previous, next) {
      next.whenData((newLog) {
        if (newLog.isNotEmpty && !_isDisposed) {
          final newEntries =
              newLog.split('\n').where((entry) => entry.isNotEmpty).toSet();

          final currentLogs = ref.read(consoleLogsProvider);
          ref.read(consoleLogsProvider.notifier).state = {
            ...currentLogs,
            ...newEntries
          };
          _trimLogs();
          _scrollToBottom();
        }
      });
    });

    ref.listenManual(serverControllerProvider, (previous, next) {
      next.whenData((data) {
        if (_isDisposed) return;

        if (data.status == ServerStatus.error && data.error != null) {
          final currentLogs = ref.read(consoleLogsProvider);
          ref.read(consoleLogsProvider.notifier).state = {
            ...currentLogs,
            data.error!
          };
          _trimLogs();
        }
        if (data.status == ServerStatus.starting) {
          ref.read(consoleLogsProvider.notifier).state = {};
        }
      });
    });
  }

  void _trimLogs() {
    final currentLogs = ref.read(consoleLogsProvider).toList();
    if (currentLogs.length > 1000) {
      ref.read(consoleLogsProvider.notifier).state =
          Set.from(currentLogs.skip(currentLogs.length - 1000));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && !_isDisposed) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(consoleLogsProvider).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        borderRadius: BorderRadius.circular(24),
      ),
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            logs.join('\n'),
            textAlign: TextAlign.start,
            style: GoogleFonts.jetBrainsMono(
              color: Theme.of(context).custom.colorTheme.dirtywhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
