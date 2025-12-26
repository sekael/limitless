import 'dart:async';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/adaptive_display.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie_service.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/cookie_card.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/cookie_edit_form.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/empty_jar.dart';
import 'package:limitless_flutter/main.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EatCookieButton extends StatelessWidget {
  const EatCookieButton({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<CookieService>();

    return AdaptiveGlassButton.async(
      buttonText: 'Eat a Cookie',
      showSpinner: false,
      onPressed: () async {
        final cookie = await _eatCookie(context);
        if (!context.mounted) return;
        unawaited(
          showAdaptiveDialogOrPage(
            context,
            cookie == null
                ? EmptyJar()
                : CookieInteractionSession(initialCookie: cookie),
            cookie == null
                ? EmptyJarPageView()
                : _CookiePageView(cookie: cookie),
          ),
        );
      },
      leadingIcon: const TextIcon(icon: '🍪', semanticLabel: 'Cookie'),
    );
  }
}

Future<Cookie?> _eatCookie(BuildContext context) async {
  try {
    return await context.read<CookieService>().next();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorSnackbar(
        message: 'Something went wrong trying to get your cookies.\n$e',
      ).build(),
    );
  }
  return null;
}

class CookieInteractionSession extends StatefulWidget {
  const CookieInteractionSession({
    super.key,
    required this.initialCookie,
    this.onPage = false,
  });

  final Cookie initialCookie;
  final bool onPage;

  @override
  State<CookieInteractionSession> createState() =>
      _CookieInteractionSessionState();
}

class _CookieInteractionSessionState extends State<CookieInteractionSession> {
  late Cookie _currentCookie;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentCookie = widget.initialCookie;
  }

  void _handleUpdate(Cookie newCookie) {
    setState(() {
      _currentCookie = newCookie;
      _isEditing = false;
    });
  }

  Future<void> _handleLoadNext() async {
    try {
      final nextCookie = await context.read<CookieService>().next();

      if (!mounted) return;
      if (nextCookie != null) {
        setState(() {
          _currentCookie = nextCookie;
        });
      }
    } catch (e, st) {
      logger.e('Could not load next cookie to display', e, st);
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(message: 'Failed to load the next cookie.').build(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _EditCookieView(
        existingCookie: _currentCookie,
        onSaved: _handleUpdate,
        onCancel: () => setState(() => _isEditing = false),
      );
    }
    return CookieCard(
      cookie: _currentCookie,
      onEditCookie: () => setState(() {
        _isEditing = true;
      }),
      onDisplayNext: _handleLoadNext,
      displayClose: !widget.onPage,
    );
  }
}

class _EditCookieView extends StatefulWidget {
  const _EditCookieView({
    required this.existingCookie,
    required this.onSaved,
    required this.onCancel,
  });

  final Cookie existingCookie;
  final ValueChanged<Cookie> onSaved; // Callback when update is successful
  final VoidCallback onCancel;

  @override
  State<_EditCookieView> createState() => _EditCookieViewState();
}

class _EditCookieViewState extends State<_EditCookieView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cookieContentCtrl;
  late bool _isPublic;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _cookieContentCtrl = TextEditingController(
      text: widget.existingCookie.content,
    );
    _isPublic = widget.existingCookie.isPublic;
  }

  @override
  void dispose() {
    _cookieContentCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateCookie() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) {
      logger.w('Form is currently not valid');
      return;
    }

    setState(() => _submitting = true);

    final updatedCookie = Cookie(
      id: widget.existingCookie.id,
      userId: widget.existingCookie.userId,
      content: _cookieContentCtrl.text.trim(),
      createdAt: widget.existingCookie.createdAt,
      isPublic: _isPublic,
    );

    try {
      logger.i(
        'Updating cookie ${updatedCookie.id} for user ${updatedCookie.userId}',
      );
      final cookieAfterUpdate = await context
          .read<CookieService>()
          .updateCookie(updatedCookie);
      logger.i('Successfully updated cookie ${updatedCookie.id}');

      if (!mounted) return;
      widget.onSaved(cookieAfterUpdate);

      rootMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Your cookie has been updated!')),
      );
    } on PostgrestException catch (e) {
      setState(() => _submitting = false);
      rootMessengerKey.currentState?.showSnackBar(
        ErrorSnackbar(message: 'Failed to edit cookie: ${e.message}').build(),
      );
    } catch (_) {
      setState(() => _submitting = false);
      rootMessengerKey.currentState?.showSnackBar(
        ErrorSnackbar(
          message: 'Something went wrong editing your cookie',
        ).build(),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          key: _formKey,
          child: CookieEditForm(
            contentController: _cookieContentCtrl,
            isPublic: _isPublic,
            onIsPublicChanged: (value) {
              if (_submitting) return;
              setState(() => _isPublic = value ?? false);
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: AdaptiveGlassButton.async(
            buttonText: 'Update Cookie',
            onPressed: _updateCookie,
          ),
        ),
        SizedBox(
          width: 200,
          child: AdaptiveGlassButton.sync(
            onPressed: _submitting ? null : widget.onCancel,
            buttonText: 'Cancel Update',
            intent: GlassButtonIntent.secondary,
          ),
        ),
      ],
    );
  }
}

class _CookiePageView extends StatelessWidget {
  final Cookie cookie;

  const _CookiePageView({required this.cookie});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Cookie Jar'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              splashColor: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  16,
                  // MediaQuery.of(context).viewInsets.bottom + 16, -> apparently not necessary because of resizeToAvoidBottomInset = true
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: CookieInteractionSession(
                    initialCookie: cookie,
                    onPage: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
