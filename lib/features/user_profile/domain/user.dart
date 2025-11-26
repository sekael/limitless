class User {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String country;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.country,
  });

  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'] as String,
    firstName: m['first_name'],
    lastName: m['last_name'],
    dateOfBirth: DateTime.parse(m['date_of_birth'] as String),
    country: m['country'],
  );

  Map<String, String> toMap() {
    return {
      "id": id,
      "first_name": firstName,
      "last_name": lastName,
      "date_of_birth": dateOfBirth.toIso8601String(),
      "country": country,
    };
  }
}
