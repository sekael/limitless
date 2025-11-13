class Cookie {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  const Cookie({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Cookie.fromMap(Map<String, dynamic> m) => Cookie(
    id: m['id'],
    userId: m['userId'],
    content: m['content'],
    createdAt: DateTime.parse(m['created_at'] as String),
  );
}
