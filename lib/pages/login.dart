import 'package:flutter/material.dart';

// TODO: make pretty
// TODO: investigate weird exception with Binding handler upon saving
// TODO: make transition home -> login smoother

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

  void _sendLoginCode() {
    // TODO: hook up to Supabase magic link / OTP here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would send login code to ${_emailCtrl.text.trim()}'),
      ),
    );
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        hintText: 'you@example.com',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) return 'Please enter your email';
                        if (!_emailRegExp.hasMatch(v))
                          return 'Enter a valid email';
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (_isValid) _sendLoginCode();
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isValid ? _sendLoginCode : null,
                        child: const Text('Send Login Code'),
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
