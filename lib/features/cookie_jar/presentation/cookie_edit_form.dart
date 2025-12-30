import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/icon.dart';

typedef CookieSubmit = Future<void> Function(String content, bool isPublic);

class CookieEditForm extends StatefulWidget {
  const CookieEditForm({
    super.key,
    required this.contentController,
    required this.isPublic,
    required this.onIsPublicChanged,
    this.title = 'Bake a Cookie!',
    this.subtitle =
        'What is something you are proud of or a moment you thoroughly cherish?',
    this.icon = '👩🏼‍🍳',
    this.semanticLabel = 'Bake Cookie',
  });

  final TextEditingController contentController;
  final bool isPublic;
  final ValueChanged<bool?> onIsPublicChanged;

  final String title;
  final String subtitle;
  final String? icon;
  final String? semanticLabel;

  @override
  State<CookieEditForm> createState() => _CookieEditFormState();
}

class _CookieEditFormState extends State<CookieEditForm> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          TextIcon(
            icon: widget.icon!,
            semanticLabel: widget.semanticLabel,
            fontSize: 32,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          widget.title,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.inversePrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        CenterAlignedBodyText(bodyText: widget.subtitle),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.contentController,
          autofocus: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          minLines: 3,
          maxLines: 5,
          maxLength: 280,
          decoration: const InputDecoration(
            labelText: 'Your accomplishment',
            hintText: 'Helped a friend with some really helpful advice!',
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            final s = v?.trim() ?? '';
            if (s.isEmpty) return 'Please write about something you enjoyed';
            if (s.length < 3) return 'That seems a little short';
            return null;
          },
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.inverseSurface,
          ),
        ),
        Row(
          children: [
            Tooltip(
              message:
                  'By sharing this accomplishment with others it becomes public and visible for other users on Limitless',
              waitDuration: const Duration(milliseconds: 750),
              child: Checkbox(
                value: widget.isPublic,
                onChanged: widget.onIsPublicChanged,
              ),
            ),
            Expanded(
              child: Text(
                'Share this accomplishment with others',
                style: TextStyle(color: colorScheme.inverseSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
