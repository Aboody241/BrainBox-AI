import '../../domain/entities/user.dart';

/// User data model with serialization support.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.password,
    super.image,
    super.createdAt,
    super.isLoggedIn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String? ?? '',
      image: json['image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      isLoggedIn: json['is_logged_in'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'is_logged_in': isLoggedIn,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      password: user.password,
      image: user.image,
      createdAt: user.createdAt,
      isLoggedIn: user.isLoggedIn,
    );
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      password: password,
      image: image,
      createdAt: createdAt,
      isLoggedIn: isLoggedIn,
    );
  }
}
