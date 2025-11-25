import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Make users set a username to be used for display of public cookies
// TODO: implement display of public cookies in dashboard (feed)

class _AddCookieView extends StatefulWidget {
  const _AddCookieView({required this.rootContext});

  final BuildContext rootContext;

  @override
  State<_AddCookieView> createState() => _AddCookieViewState();
}

class _AddCookieViewState extends State<_AddCookieView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _submitting = false;
  bool _isPublic = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final messenger = ScaffoldMessenger.of(widget.rootContext);

    final client = getSupabaseClient();
    final user = getCurrentUser();
    if (user == null) {
      messenger.showSnackBar(
        ErrorSnackbar(
          message: 'You must be logged in to add a cookie.',
        ).build(),
      );
      return;
    }

    setState(() => _submitting = true);
    final text = _controller.text.trim();

    try {
      await client.from('accomplishments').insert({
        'user_id': user.id,
        'content': text,
        'public': _isPublic,
      });

      if (Navigator.of(context).mounted) Navigator.of(context).pop();
      if (context.mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('Cookie added!')));
      }
    } on PostgrestException catch (e) {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        ErrorSnackbar(message: 'Failed to add cookie: ${e.message}').build(),
      );
    } catch (_) {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        ErrorSnackbar(message: 'Something went wrong.').build(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const TextIcon(
          icon: '👩🏼‍🍳',
          semanticLabel: 'Bake Cookie',
          fontSize: 32,
        ),
        const SizedBox(height: 12),
        Text(
          'Bake a cookie!',
          style: t.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        const SizedBox(height: 8),
        CenterAlignedBodyText(
          bodyText:
              'What is something you are proud of or a moment you thoroughly cherish?',
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            style: t.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
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
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
        Row(
          children: [
            Tooltip(
              message:
                  'By sharing this accomplishment with others it becomes public and visible for other users on Limitless',
              waitDuration: Duration(milliseconds: 750),
              child: Checkbox(
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value ?? false;
                  });
                },
              ),
            ),
            Text(
              'Share this accomplishment with others',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Not Baking Today'),
            ),
            AdaptiveGlassButton.async(
              buttonText: 'Bake the Cookie',
              onPressed: _submit,
            ),
          ],
        ),
      ],
    );
  }
}

class AddCookiePage extends StatelessWidget {
  const AddCookiePage({super.key, required this.rootContext});

  final BuildContext rootContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Bake a Cookie'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _AddCookieView(rootContext: rootContext),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> showAdaptiveAddCookiePage(
  BuildContext context,
  Widget content,
) async {
  final size = MediaQuery.sizeOf(context);
  final isWide = size.width >= 720;

  if (isWide) {
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
  } else {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (pageContext) {
          return AddCookiePage(rootContext: context);
        },
      ),
    );
  }
}

class AddCookieButton extends StatelessWidget {
  const AddCookieButton({super.key});
  @override
  Widget build(BuildContext context) {
    return AdaptiveGlassButton.sync(
      buttonText: 'Bake a Cookie',
      onPressed: () => showAdaptiveAddCookiePage(
        context,
        _AddCookieView(rootContext: context),
      ),
      leadingIcon: const TextIcon(icon: '👩🏼‍🍳', semanticLabel: 'Baker'),
    );
  }
}
