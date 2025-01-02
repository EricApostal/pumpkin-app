import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/theme/theme.dart';

class ControlButton extends ConsumerStatefulWidget {
  final String label;
  final Color color;
  final Function onPressed;

  const ControlButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ControlButtonState();
}

class _ControlButtonState extends ConsumerState<ControlButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onPressed(),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
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
