/// User entity in the Domain Layer.
class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? image;
  final DateTime? createdAt;
  final bool isLoggedIn;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.image,
    this.createdAt,
    this.isLoggedIn = false,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? image,
    DateTime? createdAt,
    bool? isLoggedIn,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.password == password &&
        other.image == image &&
        other.createdAt == createdAt &&
        other.isLoggedIn == isLoggedIn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        password.hashCode ^
        image.hashCode ^
        createdAt.hashCode ^
        isLoggedIn.hashCode;
  }
}
