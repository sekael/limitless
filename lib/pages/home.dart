import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                    TitleText(
                      titleText: "Hello there!",
                      colorOverride: Colors.white,
                    ),
                    CenterAlignedBodyText(
                      bodyText:
                          "More coming soon...\nmaybe ...\nwhen I find time.",
                      colorOverride: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
