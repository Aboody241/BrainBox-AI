import 'package:brain_box_ai/features/auth/data/models/user_model.dart';
import 'package:brain_box_ai/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Entity & Model Tests', () {
    const user = User(
      id: 'usr_1',
      username: 'johndoe',
      email: 'john@example.com',
      password: 'password123',
      image: 'https://example.com/avatar.png',
      isLoggedIn: true,
    );

    test('User copyWith updates fields correctly', () {
      final updated = user.copyWith(username: 'newjohn');
      expect(updated.username, equals('newjohn'));
      expect(updated.email, equals('john@example.com'));
    });

    test('UserModel converts to/from json correctly', () {
      final model = UserModel.fromEntity(user);
      final json = model.toJson();

      expect(json['id'], equals('usr_1'));
      expect(json['username'], equals('johndoe'));
      expect(json['email'], equals('john@example.com'));
      expect(json['password'], equals('password123'));
      expect(json['image'], equals('https://example.com/avatar.png'));

      final restored = UserModel.fromJson(json).toEntity();
      expect(restored, equals(user));
    });
  });
}
