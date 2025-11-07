import 'dart:math';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/theme_toggle.dart';
import 'package:limitless_flutter/features/quotes/data/repository.dart';
import 'package:limitless_flutter/features/quotes/domain/quote.dart';
import 'package:limitless_flutter/features/quotes/presentation/quote_display.dart';
import 'package:provider/provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init();

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
        talker.warning('Could not retrieve any items from the repository');
        setState(() {
          _currentQuote = null;
          _isLoading = false;
        });
        return;
      }

      talker.info(
        'Successfully retrieved ${items.length} items from repository',
      );

      final r = Random.secure();
      final idx = r.nextInt(items.length);
      final randomQuote = items[idx];
      talker.info('Successfully picked random quote');

      setState(() {
        _currentQuote = randomQuote;
        _isLoading = false;
      });
    } catch (e) {
      talker.error(
        'An error occurred while loading and picking quote: ${e.toString()}',
      );
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
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: FractionalOffset(0.5, 0.35),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: QuoteDisplay(quote: _currentQuote!),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: SizedBox(
                            width: 200,
                            child: AdaptiveButton(
                              buttonText: 'Login',
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PositionedDirectional(bottom: 0, end: 0, child: ThemeToggle()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
