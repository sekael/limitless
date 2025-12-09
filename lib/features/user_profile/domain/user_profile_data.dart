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

  factory UserProfileData.fromMap(Map<String, dynamic> m) {
    DateTime? dob;
    final dobRaw = m['date_of_birth'];
    if (dobRaw is String && dobRaw.isNotEmpty) {
      dob = DateTime.parse(dobRaw);
    } else {
      dob = null;
    }
    return UserProfileData(
      id: m['id'] as String,
      username: m['username'] as String?,
      firstName: m['first_name'] as String?,
      lastName: m['last_name'] as String?,
      dateOfBirth: dob,
      country: m['country'] as String?,
    );
  }

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

  String prettyPrintBirthday() {
    if (dateOfBirth == null) {
      throw Exception('Cannot pretty-print non-existing birthdate');
    }

    return '${dateOfBirth!.day.toString().padLeft(2, '0')}.${dateOfBirth!.month.toString().padLeft(2, '0')}.${dateOfBirth!.year}';
  }
}
