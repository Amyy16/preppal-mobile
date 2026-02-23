import 'package:prepal2/data/models/auth/user_model.dart';

abstract class AuthRemoteDataSource {
	Future<UserModel> login({
		required String email,
		required String password,
	});

	Future<UserModel> signup({
		required String username,
		required String email,
		required String password,
		required String businessName,
	});
}

class MockAuthDataSource implements AuthRemoteDataSource {
	final Map<String, _MockUserRecord> _users = {};

	@override
	Future<UserModel> login({
		required String email,
		required String password,
	}) async {
		await Future.delayed(const Duration(milliseconds: 600));

		final record = _users[email.toLowerCase()];
		if (record == null) {
			throw Exception('User not found');
		}

		if (record.password != password) {
			throw Exception('Incorrect password');
		}

		return record.user;
	}

	@override
	Future<UserModel> signup({
		required String username,
		required String email,
		required String password,
		required String businessName,
	}) async {
		await Future.delayed(const Duration(milliseconds: 600));

		final key = email.toLowerCase();
		if (_users.containsKey(key)) {
			throw Exception('User already exists');
		}

		final user = UserModel(
			id: 'user_${DateTime.now().millisecondsSinceEpoch}',
			username: username,
			email: email,
			businessName: businessName,
		);

		_users[key] = _MockUserRecord(user: user, password: password);
		return user;
	}
}

class _MockUserRecord {
	final UserModel user;
	final String password;

	const _MockUserRecord({
		required this.user,
		required this.password,
	});
}
