class Quote {
  final int id;
  final DateTime createdAt;
  final String text;

  const Quote({required this.id, required this.createdAt, required this.text});

  factory Quote.fromMap(Map<String, dynamic> m) => Quote(
    id: (m['id'] as num).toInt(),
    createdAt: DateTime.parse(m['created_at'] as String),
    text: m['quote'] as String,
  );
}
