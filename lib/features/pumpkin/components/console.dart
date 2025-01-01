import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pumpkin_app/features/pumpkin/controllers/server.dart';
import 'package:pumpkin_app/theme/theme.dart';

class Console extends ConsumerStatefulWidget {
  const Console({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConsoleState();
}

class _ConsoleState extends ConsumerState<Console> {
  @override
  Widget build(BuildContext context) {
    String? stream = ref.watch(serverLogsProvider).when(
          data: (logs) => logs,
          loading: () => null,
          error: (error, _) => null,
        );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: (stream != null)
                  ? Text(
                      stream,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.jetBrainsMono(
                        color: Theme.of(context).custom.colorTheme.dirtywhite,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Text(
                      "",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.jetBrainsMono(
                        color: Theme.of(context).custom.colorTheme.dirtywhite,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
        ),
      ),
    );
  }
}
