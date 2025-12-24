import 'package:flutter/material.dart';
import 'package:limitless_flutter/core/require_session.dart';
import 'package:limitless_flutter/pages/registration.dart';

class RegistrationGate extends StatelessWidget {
  const RegistrationGate({super.key});

  @override
  Widget build(BuildContext context) {
    return RequireSessionGate(
      redirectRoute: '/',
      showLoginErrorWhenNotAuthenticated: true,
      loginErrorMessage:
          'Something went wrong logging you in, please try again.',
      child: RegistrationPage(),
    );
  }
}
