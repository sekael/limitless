class Cookie {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final bool isPublic;

  const Cookie({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.isPublic,
  });

  factory Cookie.fromMap(Map<String, dynamic> m) => Cookie(
    id: m['id'],
    userId: m['user_id'],
    content: m['content'],
    createdAt: DateTime.parse(m['created_at'] as String),
    isPublic: m['is_public'] as bool,
  );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "user_id": userId,
      "content": content,
      "created_at": createdAt.toIso8601String(),
      "is_public": isPublic,
    };
  }
}
