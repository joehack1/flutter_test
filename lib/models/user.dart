class User {
  final int? id; // Nullable to handle API nulls
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
    return User(
      id: json['id'] as int?, // Safely handle null
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'occupation': occupation,
    'bio': bio,
  };
}
