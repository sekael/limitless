class UserProfileData {
  final String id;
  String? username;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? country;

  UserProfileData({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.country,
  });

  factory UserProfileData.fromMap(Map<String, dynamic> m) => UserProfileData(
    id: m['id'] as String,
    username: m['username'],
    firstName: m['first_name'],
    lastName: m['last_name'],
    dateOfBirth: DateTime.parse(m['date_of_birth'] as String),
    country: m['country'],
  );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "first_name": firstName,
      "last_name": lastName,
      "date_of_birth": dateOfBirth?.toIso8601String(),
      "country": country,
    };
  }

  bool isComplete() {
    return (username != null && username!.trim().isNotEmpty) &&
        (firstName != null && firstName!.trim().isNotEmpty) &&
        (lastName != null && lastName!.trim().isNotEmpty) &&
        (dateOfBirth != null) &&
        (country != null && country!.trim().isNotEmpty);
  }
}
