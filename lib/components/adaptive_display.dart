import 'package:flutter/material.dart';
import 'package:limitless_flutter/config/constants.dart';

Future<void> adaptiveShowDialogOrBottomSheet(
  BuildContext context,
  Widget content,
) async {
  final size = MediaQuery.sizeOf(context);
  final isWide = size.width >= SMALL_SCREEN_THRESHOLD;

  if (!isWide) {
    // Mobile or small screens
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: size.height / 2,
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: content,
        ),
      ),
    );
  } else {
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
          child: Padding(padding: const EdgeInsets.all(24), child: content),
        ),
      ),
    );
  }
}

Future<void> adaptiveShowDialogOrPage(
  BuildContext context,
  Widget dialogContent,
  WidgetBuilder pageBuilder,
) async {
  final size = MediaQuery.sizeOf(context);
  final isWide = size.width >= SMALL_SCREEN_THRESHOLD;

  if (isWide) {
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: dialogContent,
          ),
        ),
      ),
    );
  } else {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(fullscreenDialog: true, builder: pageBuilder));
  }
}
