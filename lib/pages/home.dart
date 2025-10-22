import 'dart:math';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/theme_toggle.dart';
import 'package:limitless_flutter/features/quotes/data/repository.dart';
import 'package:limitless_flutter/features/quotes/domain/quote.dart';
import 'package:limitless_flutter/features/quotes/presentation/quote_display.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Quote? _currentQuote;
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAndPick();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadAndPick() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = context.read<QuotesRepository>();
      final items = await repo.getAll();
      if (!mounted) return;

      if (items.isEmpty) {
        setState(() {
          _currentQuote = null;
          _isLoading = false;
        });
        return;
      }

      final r = Random.secure();
      final idx = r.nextInt(items.length);
      final randomQuote = items[idx];

      setState(() {
        _currentQuote = randomQuote;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _currentQuote = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            alignment: AlignmentGeometry.center,
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: FractionalOffset(0.5, 0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading) ...[
                      const CircularProgressIndicator(),
                    ] else if (_error != null) ...[
                      CenterAlignedBodyText(
                        bodyText: 'Struggling to find inspiration today',
                      ),
                    ] else if (_currentQuote == null) ...[
                      CenterAlignedBodyText(
                        bodyText: 'We will be back to inspire you soon...',
                      ),
                    ] else ...[
                      QuoteDisplay(quote: _currentQuote!),
                    ],
                  ],
                ),
              ),
              PositionedDirectional(bottom: 0, end: 0, child: ThemeToggle()),
            ],
          ),
        ),
      ),
    );
  }
}
