import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:prepal2/data/datasources/auth/auth_remote_datasource.dart';
import 'package:prepal2/data/models/auth/user_model.dart';
import 'package:prepal2/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
	static const _sessionKey = 'auth_user';

	final AuthRemoteDataSource remoteDataSource;
	final SharedPreferences sharedPreferences;

	AuthRepositoryImpl({
		required this.remoteDataSource,
		required this.sharedPreferences,
	});

	@override
	Future<UserModel> login({
		required String email,
		required String password,
	}) async {
		final user = await remoteDataSource.login(
			email: email,
			password: password,
		);
		await _saveSession(user);
		return user;
	}

	@override
	Future<UserModel> signup({
		required String username,
		required String email,
		required String password,
		required String businessName,
	}) async {
		final user = await remoteDataSource.signup(
			username: username,
			email: email,
			password: password,
			businessName: businessName,
		);
		await _saveSession(user);
		return user;
	}

	@override
	Future<void> logout() async {
		await sharedPreferences.remove(_sessionKey);
	}

	@override
	Future<UserModel?> getLoggedInUser() async {
		final jsonString = sharedPreferences.getString(_sessionKey);
		if (jsonString == null) return null;

		final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
		return UserModel.fromJson(jsonMap);
	}

	Future<void> _saveSession(UserModel user) async {
		final jsonString = json.encode(user.toJson());
		await sharedPreferences.setString(_sessionKey, jsonString);
	}
}
