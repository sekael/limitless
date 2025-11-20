import 'package:flutter/material.dart';

Future<void> showAdaptiveCookieReveal(
  BuildContext context,
  Widget content,
) async {
  final size = MediaQuery.sizeOf(context);
  final isWide = size.width >= 720;

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
      constraints: BoxConstraints(minWidth: size.width, maxWidth: size.width),
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
          constraints: const BoxConstraints(minWidth: 720, maxWidth: 800),
          child: Padding(padding: const EdgeInsets.all(24), child: content),
        ),
      ),
    );
  }
}
