import 'package:flutter/material.dart';
import 'package:prepal2/data/models/auth/user_model.dart';
import 'package:prepal2/domain/repositories/auth_repository.dart';
import 'package:prepal2/domain/usercases/login_usercase.dart';
import 'package:prepal2/domain/usercases/signup_usercase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
	final LoginUseCase loginUseCase;
	final SignupUseCase signupUseCase;
	final AuthRepository authRepository;

	AuthStatus _status = AuthStatus.initial;
	UserModel? _currentUser;
	String? _errorMessage;

	AuthProvider({
		required this.loginUseCase,
		required this.signupUseCase,
		required this.authRepository,
	}) {
		_resolveSession();
	}

	AuthStatus get status => _status;
	UserModel? get currentUser => _currentUser;
	String? get errorMessage => _errorMessage;
	bool get isLoading => _status == AuthStatus.loading;

	Future<void> _resolveSession() async {
		_status = AuthStatus.loading;
		notifyListeners();

		try {
			final user = await authRepository.getLoggedInUser();
			if (user != null) {
				_currentUser = user;
				_status = AuthStatus.authenticated;
			} else {
				_status = AuthStatus.unauthenticated;
			}
		} catch (e) {
			_errorMessage = _cleanError(e);
			_status = AuthStatus.error;
		}

		notifyListeners();
	}

	Future<bool> login({
		required String email,
		required String password,
	}) async {
		_status = AuthStatus.loading;
		_errorMessage = null;
		notifyListeners();

		try {
			final user = await loginUseCase(
				email: email,
				password: password,
			);
			_currentUser = user;
			_status = AuthStatus.authenticated;
			notifyListeners();
			return true;
		} catch (e) {
			_errorMessage = _cleanError(e);
			_status = AuthStatus.unauthenticated;
			notifyListeners();
			return false;
		}
	}

	Future<bool> signup({
		required String username,
		required String email,
		required String password,
		required String businessName,
	}) async {
		_status = AuthStatus.loading;
		_errorMessage = null;
		notifyListeners();

		try {
			final user = await signupUseCase(
				username: username,
				email: email,
				password: password,
				confirmPassword: password,
				businessName: businessName,
			);
			_currentUser = user;
			_status = AuthStatus.authenticated;
			notifyListeners();
			return true;
		} catch (e) {
			_errorMessage = _cleanError(e);
			_status = AuthStatus.unauthenticated;
			notifyListeners();
			return false;
		}
	}

	Future<void> logout() async {
		await authRepository.logout();
		_currentUser = null;
		_status = AuthStatus.unauthenticated;
		notifyListeners();
	}

	void clearError() {
		_errorMessage = null;
		notifyListeners();
	}

	String _cleanError(Object e) {
		return e.toString().replaceAll('Exception: ', '');
	}
}
