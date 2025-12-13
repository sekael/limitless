import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/icon.dart';

typedef CookieSubmit = Future<void> Function(String content, bool isPublic);

class CookieEditForm extends StatefulWidget {
  const CookieEditForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    required this.initialText,
    required this.initialIsPublic,
    this.icon,
    this.semanticLabel,
  });

  final String title;
  final String subtitle;
  final String submitLabel;

  final String? initialText;
  final bool initialIsPublic;

  final String? icon;
  final String? semanticLabel;

  @override
  State<CookieEditForm> createState() => _CookieEditFormState();
}

class _CookieEditFormState extends State<CookieEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late bool _isPublic;
  final bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialText ?? '');
    _isPublic = widget.initialIsPublic;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

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
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _contentController,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            maxLength: 280,
            textInputAction: TextInputAction.done,
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
            onFieldSubmitted: (_) => widget.onSubmit,
          ),
        ),
        Row(
          children: [
            Tooltip(
              message:
                  'By sharing this accomplishment with others it becomes public and visible for other users on Limitless',
              waitDuration: const Duration(milliseconds: 750),
              child: Checkbox(
                value: _isPublic,
                onChanged: _submitting
                    ? null
                    : (value) => setState(() => _isPublic = value ?? false),
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
