class UserProfileData {
  final String id;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? country;

  UserProfileData({
    required this.id,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.country,
  });

  factory UserProfileData.fromMap(Map<String, dynamic> m) => UserProfileData(
    id: m['id'] as String,
    firstName: m['first_name'],
    lastName: m['last_name'],
    dateOfBirth: DateTime.parse(m['date_of_birth'] as String),
    country: m['country'],
  );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "first_name": firstName,
      "last_name": lastName,
      "date_of_birth": dateOfBirth?.toIso8601String(),
      "country": country,
    };
  }

  bool isComplete() {
    return (firstName != null && firstName!.trim().isNotEmpty) &&
        (lastName != null && lastName!.trim().isNotEmpty) &&
        (country != null && country!.trim().isNotEmpty);
  }
}
