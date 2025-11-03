import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailOtpVerificationPage extends StatefulWidget {
  const EmailOtpVerificationPage({super.key});

  @override
  State<EmailOtpVerificationPage> createState() => _EmailOtpVerificationState();
}

// TODO: Make pretty

class _EmailOtpVerificationState extends State<EmailOtpVerificationPage> {
  final _verificationCodeControl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _verificationCodeControl.dispose();
    super.dispose();
  }

  Future<void> _verify(String email) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      // Verify OTP verification code
      final AuthResponse response = await Supabase.instance.client.auth
          .verifyOTP(
            type: OtpType.email,
            token: _verificationCodeControl.text.trim(),
            email: email,
          );
      final session = response.session;
      if (session != null) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/dashboard', (_) => false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackbar(
            message:
                'We could not log you in because email verification failed.',
          ).build(),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(
          message: 'Code verification failed: ${e.message}',
        ).build(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(ErrorSnackbar(message: 'Something went wrong').build());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Enter Code'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'We emailed a 8-digit code to\n$email',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _verificationCodeControl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      labelText: 'OTP code',
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _verify(email),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : () => _verify(email),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Supabase.instance.client.auth
                              .signInWithOtp(email: email) // resend
                              .then(
                                (_) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Code resent'),
                                      ),
                                    ),
                              )
                              .catchError(
                                (_) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not resend'),
                                      ),
                                    ),
                              ),
                    child: const Text('Resend code'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
