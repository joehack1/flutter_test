class User {
  final int id;
  final String name;
  final String email;
  final String occupation;
  final String bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.occupation,
    required this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      occupation: json['occupation'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'occupation': occupation,
        'bio': bio,
      };
}