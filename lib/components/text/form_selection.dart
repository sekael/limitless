import 'package:flutter/material.dart';

class FormSelectionText extends StatelessWidget {
  final String? inputText;
  final String hintText;

  const FormSelectionText({super.key, this.inputText, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Text(
      inputText ?? hintText,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: inputText == null
            ? Theme.of(context).hintColor
            : Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }
}
