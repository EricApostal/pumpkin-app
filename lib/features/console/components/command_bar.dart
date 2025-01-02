import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:pumpkin_app/features/pumpkin/controllers/server.dart';
import 'package:pumpkin_app/theme/theme.dart';
import 'package:universal_platform/universal_platform.dart';

class EnterKeyFormatter extends TextInputFormatter {
  final bool isShiftPressed;
  final bool isDesktop;

  EnterKeyFormatter({
    required this.isShiftPressed,
    required this.isDesktop,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.endsWith('\n') && !isShiftPressed && isDesktop) {
      return oldValue;
    }
    return newValue;
  }
}

class CommandBarController {
  void attach(VoidCallback focusCallback) {}
}

class CommandBar extends ConsumerStatefulWidget {
  final CommandBarController controller;

  const CommandBar({super.key, required this.controller});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommandBarState();
}

class _CommandBarState extends ConsumerState<CommandBar> {
  late FocusNode commandBarFocusNode;
  bool _isShiftPressed = false;
  late HorizontalDragGestureRecognizer _attachmentDragRecognizer;
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commandBarFocusNode = FocusNode();
    widget.controller.attach(() => commandBarFocusNode.requestFocus());
  }

  @override
  void dispose() {
    textController.dispose();
    commandBarFocusNode.dispose();
    _attachmentDragRecognizer.dispose();
    super.dispose();
  }

  Widget _commandBarIcon(SvgPicture icon, void Function() onPressed,
      {Color? backgroundColor, BorderRadius? borderRadius}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? Theme.of(context).custom.colorTheme.foreground,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Center(child: icon),
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event, bool isDesktop) {
    if (event is KeyDownEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.shiftLeft ||
          event.physicalKey == PhysicalKeyboardKey.shiftRight) {
        setState(() => _isShiftPressed = true);
      } else if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !_isShiftPressed &&
          isDesktop) {
        _sendMessage();
      }
    } else if (event is KeyUpEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.shiftLeft ||
          event.physicalKey == PhysicalKeyboardKey.shiftRight) {
        setState(() => _isShiftPressed = false);
      }
    }
  }

  void _sendMessage() {
    final message = textController.text.trim();
    if (message.isNotEmpty) {
      ref.read(serverControllerProvider.notifier).sendCommand(message);
      setState(() {
        textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).custom.colorTheme.foreground,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 4 * 24,
                      ),
                      child: TextSelectionTheme(
                        data: TextSelectionThemeData(
                          cursorColor:
                              Theme.of(context).custom.colorTheme.primary,
                          selectionColor:
                              Theme.of(context).custom.colorTheme.primary,
                          selectionHandleColor:
                              Theme.of(context).custom.colorTheme.primary,
                        ),
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (event) => _handleKeyEvent(event, false),
                          child: TextField(
                            focusNode: commandBarFocusNode,
                            controller: textController,
                            maxLines: null,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            onSubmitted: (_) => _sendMessage(),
                            inputFormatters: [
                              EnterKeyFormatter(
                                isShiftPressed: _isShiftPressed,
                                isDesktop: false,
                              ),
                            ],
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              hintText: "Send Command",
                              hintStyle: GoogleFonts.publicSans(
                                color: Theme.of(context)
                                    .custom
                                    .colorTheme
                                    .secondary,
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                              isCollapsed: false,
                            ),
                            style: GoogleFonts.publicSans(
                              color: Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .dirtywhite,
                              fontWeight: FontWeight.w500,
                            ),
                            cursorColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (UniversalPlatform.isMobile || UniversalPlatform.isWeb)
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0, right: 4.0),
                        child: _commandBarIcon(
                          SvgPicture.asset(
                            "assets/icons/send.svg",
                            width: 20,
                            height: 20,
                          ),
                          _sendMessage,
                          backgroundColor:
                              Theme.of(context).custom.colorTheme.primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
