import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pumpkin_app/theme/theme.dart';

class ServerHeader extends ConsumerWidget {
  final String serverName;
  const ServerHeader({
    super.key,
    required this.serverName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
        onTap: () {},
        splashFactory: NoSplash.splashFactory,
        highlightColor: Theme.of(context).custom.colorTheme.foreground,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            serverName,
            style: GoogleFonts.publicSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ));
  }
}
