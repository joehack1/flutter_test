class User {
  final String? id;
  final String name;
  final String email;
  final String occupation;
  final String bio;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.occupation,
    required this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int? parsedId;
    try {
      parsedId = int.tryParse(json['_id'] as String);
      if (parsedId == null) {
        print("Warning: Failed to parse '_id' as int: ${json['_id']}");
      }
    } catch (e) {
      print("Error parsing '_id' as int: $e");
    }

    return User(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? 'No email',
      occupation: json['occupation'] as String? ?? 'No occupation',
      bio: json['bio'] as String? ?? 'No bio',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'occupation': occupation,
      'bio': bio,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? occupation,
    String? bio,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      bio: bio ?? this.bio,
    );
  }
}
