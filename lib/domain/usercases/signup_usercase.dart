import 'package:prepal2/domain/entities/user_entity.dart';
import 'package:prepal2/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase({required this.repository});

  Future<UserEntity> call({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String businessName,
  }) async {
    // validation (business rules go here)
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || businessName.isEmpty) {
      throw Exception('All fields are required');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    return await repository.signup(
      username: username,
      email: email,
      password: password,
      businessName: businessName,
    );
  }
}