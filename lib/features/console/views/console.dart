import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pumpkin_app/features/pumpkin/controllers/server.dart';
import 'package:pumpkin_app/features/pumpkin/models/server.dart';
import 'package:pumpkin_app/theme/theme.dart';

class Console extends ConsumerStatefulWidget {
  const Console({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConsoleState();
}

class _ConsoleState extends ConsumerState<Console> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _logEntries = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(serverLogsProvider).whenData((newLog) {
      if (newLog.isNotEmpty) {
        final newEntries =
            newLog.split('\n').where((entry) => entry.isNotEmpty);

        setState(() {
          _logEntries.addAll(newEntries);

          if (_logEntries.length > 1000) {
            _logEntries.removeRange(0, _logEntries.length - 1000);
          }
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    ref.watch(serverControllerProvider).when(
          data: (data) {
            if (data.status == ServerStatus.error) {
              _logEntries.add(data.error!);
            }
            if (data.status == ServerStatus.starting) {
              _logEntries.clear();
            }
          },
          loading: () {},
          error: (error, stack) {
            _logEntries.add(error.toString());
          },
        );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              _logEntries.join('\n'),
              textAlign: TextAlign.start,
              style: GoogleFonts.jetBrainsMono(
                color: Theme.of(context).custom.colorTheme.dirtywhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
