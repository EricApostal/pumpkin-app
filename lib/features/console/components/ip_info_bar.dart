import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/console/repositories/ip.dart';
import 'package:pumpkin_app/theme/theme.dart';

class IpInfoBar extends ConsumerStatefulWidget {
  const IpInfoBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IpInfoBarState();
}

class _IpInfoBarState extends ConsumerState<IpInfoBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localIp = ref.watch(localIpProvider).valueOrNull;
    final publicIp = ref.watch(publicIpProvider).valueOrNull;
    return Row(
      children: [
        Expanded(child: IpInfoCard(ip: localIp, label: "Local IP")),
        const SizedBox(width: 8),
        Expanded(
            child: IpInfoCard(
          ip: publicIp,
          label: "Public IP",
        )),
      ],
    );
  }
}

class IpInfoCard extends ConsumerWidget {
  final String? ip;
  final String label;
  const IpInfoCard({
    super.key,
    this.ip,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).custom.textTheme.bodyText2.copyWith(
                    color: Theme.of(context)
                        .custom
                        .colorTheme
                        .dirtywhite
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              ip ?? "placeholder",
              style: Theme.of(context).custom.textTheme.bodyText1.copyWith(
                    color: Theme.of(context).custom.colorTheme.dirtywhite,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
