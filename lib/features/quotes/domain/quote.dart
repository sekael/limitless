class Quote {
  final int id;
  final DateTime createdAt;
  final String quote;

  const Quote({required this.id, required this.createdAt, required this.quote});

  factory Quote.fromMap(Map<String, dynamic> m) => Quote(
    id: (m['id'] as num).toInt(),
    createdAt: DateTime.parse(m['created_at'] as String),
    quote: m['quote'] as String,
  );
}
