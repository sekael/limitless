import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/title.dart';
import 'package:limitless_flutter/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isValid = false;

  // Simple RFC5322-ish email regex (good enough for UI validation)
  static final _emailRegExp = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final valid = _emailRegExp.hasMatch(_emailCtrl.text.trim());
    if (valid != _isValid) {
      setState(() => _isValid = valid);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendLoginCode() async {
    final String email = _emailCtrl.text.trim();
    try {
      await sendEmailOtp(email);
      if (!mounted) return;
      Navigator.of(context).pushNamed('/verify', arguments: email);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(
          message: 'Error occurred when authenticating: ${e.message}',
        ).build(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(
          message: 'Could not send verification code. Please try again',
        ).build(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Align(
          alignment: FractionalOffset(0.5, 0.3),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitleText(titleText: 'Welcome back!'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        hintText: 'you@example.com',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) return 'Please enter your email';
                        if (!_emailRegExp.hasMatch(v)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        _isValid ? () => _sendLoginCode() : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AdaptiveGlassButton.async(
                        onPressed: _sendLoginCode,
                        buttonText: 'Send Login Code',
                        loadingText: 'Sending Code ...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
