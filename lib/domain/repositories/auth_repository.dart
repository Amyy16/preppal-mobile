import 'package:prepal2/domain/entities/user_entity.dart';

abstract class AuthRepository {
	// Returns a UserEntity on success, throws an Exception on failure.
	Future<UserEntity> login({
		required String email,
		required String password,
	});

	Future<UserEntity> signup({
		required String username,
		required String email,
		required String password,
		required String businessName,
	});

	// Clears saved session data.
	Future<void> logout();

	// Checks if a user session exists (for auto-login on app start).
	Future<UserEntity?> getLoggedInUser();
}
