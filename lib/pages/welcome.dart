import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/text/title.dart';

// TODO: implement dashboard
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Limitless!')),
      body: Center(child: const TitleText(titleText: 'Welcome to Limitless!')),
    );
  }
}
