import 'package:flutter/material.dart';
import 'package:limitless_flutter/config/constants.dart';

Future<void> showAdaptiveDialogOrPage(
  BuildContext context,
  Widget dialogChild,
  Widget? pageChild,
) async {
  final size = MediaQuery.sizeOf(context);
  final isWide = size.width >= SMALL_SCREEN_THRESHOLD;

  if (isWide) {
    // Desktop and wide screens
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: SMALL_SCREEN_THRESHOLD,
            maxWidth: SMALL_SCREEN_MAX_WIDTH,
          ),
          child: Padding(padding: const EdgeInsets.all(24), child: dialogChild),
        ),
      ),
    );
  } else {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (pageContext) {
          return pageChild ?? dialogChild;
        },
      ),
    );
  }
}
