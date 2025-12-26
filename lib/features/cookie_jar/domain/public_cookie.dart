class PublicCookie {
  final String id;
  final String username;
  final String content;
  final DateTime createdAt;

  const PublicCookie({
    required this.id,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory PublicCookie.fromMap(Map<String, dynamic> m) {
    return PublicCookie(
      id: m['id'],
      username: m['author_username'] as String? ?? 'Anonymous',
      content: m['content'],
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
