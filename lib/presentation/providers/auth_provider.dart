import 'package:flutter/material.dart';
import 'package:prepal2/data/models/auth/user_model.dart';
import 'package:prepal2/domain/repositories/auth_repository.dart';
import 'package:prepal2/domain/usercases/login_usercase.dart';
import 'package:prepal2/domain/usercases/signup_usercase.dart';
import 'package:prepal2/core/di/service_locator.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
	final LoginUseCase loginUseCase;
	final SignupUseCase signupUseCase;
	final AuthRepository authRepository;

	AuthStatus _status = AuthStatus.initial;
	UserModel? _currentUser;
	String? _errorMessage;
	String? _userEmail; // Store email for verification screen

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
	String? get userEmail => _userEmail;
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
			// Call real backend API
			final authDataSource = serviceLocator.authRemoteDataSource;
			final response = await authDataSource.login(
				email: email,
				password: password,
			);

			// Store email for later use
			_userEmail = email;

			// Create user model from response
			_currentUser = UserModel(
				id: response['user']['id'] ?? '',
				email: response['user']['email'] ?? '',
				username: response['user']['username'] ?? '',
				businessName: response['user']['business_name'] ?? '',
			);

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
	}) async {
		_status = AuthStatus.loading;
		_errorMessage = null;
		notifyListeners();

		try {
			// Call real backend API
			final authDataSource = serviceLocator.authRemoteDataSource;
			final response = await authDataSource.register(
				email: email,
				username: username,
				password: password,
			);

			// Store email for verification screen
			_userEmail = email;

			// Create user model from response
			_currentUser = UserModel(
				id: response['id'] ?? '',
				email: response['email'] ?? '',
				username: response['username'] ?? '',
				businessName: '',
			);

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

	/// Verify email with OTP code
	Future<bool> verifyEmail({
		required String email,
		required String code,
	}) async {
		_status = AuthStatus.loading;
		_errorMessage = null;
		notifyListeners();

		try {
			final authDataSource = serviceLocator.authRemoteDataSource;
			await authDataSource.verifyEmail(
				email: email,
				code: code,
			);

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

	/// Resend verification email
	Future<bool> resendVerificationEmail(String email) async {
		_status = AuthStatus.loading;
		_errorMessage = null;
		notifyListeners();

		try {
			final authDataSource = serviceLocator.authRemoteDataSource;
			await authDataSource.resendVerificationEmail(email);

			_errorMessage = 'Verification code sent to $email';
			_status = AuthStatus.unauthenticated;
			notifyListeners();
			return true;
		} catch (e) {
			_errorMessage = _cleanError(e);
			_status = AuthStatus.error;
			notifyListeners();
			return false;
		}
	}

	Future<void> logout() async {
		await authRepository.logout();
		// Also clear token from API client
		await serviceLocator.apiClient.clearAuthToken();
		_currentUser = null;
		_userEmail = null;
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
