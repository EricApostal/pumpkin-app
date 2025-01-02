import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ServerHeader extends ConsumerWidget {
  final String serverName;
  const ServerHeader({
    super.key,
    required this.serverName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
        onPressed: () {},
        child: Text(
          serverName,
          style: GoogleFonts.publicSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ));
  }
}
