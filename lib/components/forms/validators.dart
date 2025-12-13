extension TextInpuValidation on String {
  static final allowedCharactersRegex = RegExp(r'^[a-zA-Z0-9-]+$');

  // Allow latin letters, optional combining marks, enforce capitalized start letter
  // E.g. Müller, D'Amico, Álvaro, Jean-Luc are valid
  static final validNameRegex = RegExp(
    r"^(?:(?=\p{Lu})\p{Script=Latin}\p{M}*)(?:\p{Script=Latin}\p{M}*)*(?:[ '-](?:\p{Script=Latin}\p{M}*)+)*$",
    unicode: true,
  );

  bool get containsOnlyValidCharacters => allowedCharactersRegex.hasMatch(this);
  bool get isValidName => validNameRegex.hasMatch(this);
}
