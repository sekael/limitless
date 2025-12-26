import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/adaptive_display.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie_service.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/cookie_edit_form.dart';
import 'package:limitless_flutter/main.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCookieButton extends StatelessWidget {
  const AddCookieButton({super.key});
  @override
  Widget build(BuildContext context) {
    final collection = context.read<CookieService>();

    return AdaptiveGlassButton.sync(
      buttonText: 'Bake a Cookie',
      onPressed: () => showAdaptiveDialogOrPage(
        context,
        ChangeNotifierProvider.value(
          value: collection,
          child: _AddCookieView(rootContext: context),
        ),
        ChangeNotifierProvider.value(
          value: collection,
          child: AddCookiePage(rootContext: context),
        ),
      ),
      leadingIcon: const TextIcon(icon: '👩🏼‍🍳', semanticLabel: 'Baker'),
    );
  }
}

class _AddCookieView extends StatefulWidget {
  const _AddCookieView({required this.rootContext});

  final BuildContext rootContext;

  @override
  State<_AddCookieView> createState() => _AddCookieViewState();
}

class _AddCookieViewState extends State<_AddCookieView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cookieContentCtrl;
  late bool _isPublic;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _cookieContentCtrl = TextEditingController();
    _isPublic = false;
  }

  @override
  void dispose() {
    _cookieContentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) {
      logger.w('Form is currently not valid');
      return;
    }

    setState(() => _submitting = true);
    final text = _cookieContentCtrl.text.trim();
    try {
      final userId = getCurrentUser().id;
      logger.i('Adding new cookie for user $userId');
      await context.read<CookieService>().addNewCookie(userId, text, _isPublic);
      logger.i('Successfully added new cookie for user $userId');

      if (!mounted) return;
      Navigator.of(context).pop();
      rootMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Awesome, you baked a new cookie!')),
      );
    } on PostgrestException catch (e) {
      setState(() => _submitting = false);
      rootMessengerKey.currentState?.showSnackBar(
        ErrorSnackbar(message: 'Failed to add cookie: ${e.message}').build(),
      );
    } catch (_) {
      setState(() => _submitting = false);
      rootMessengerKey.currentState?.showSnackBar(
        ErrorSnackbar(message: 'Something went wrong.').build(),
      );
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
            buttonText: 'Bake the Cookie',
            onPressed: _submit,
          ),
        ),
        SizedBox(
          width: 200,
          child: AdaptiveGlassButton.sync(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            buttonText: 'Not Baking Today',
            intent: GlassButtonIntent.secondary,
          ),
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
                16,
                // MediaQuery.of(context).viewInsets.bottom + 16, -> apparently not necessary because of resizeToAvoidBottomInset = true
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
