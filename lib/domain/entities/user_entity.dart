class UserEntity {
	final String id;
	final String username;
	final String email;
	final String businessName;
	final String? token; // JWT token (optional)

	const UserEntity({
		required this.id,
		required this.username,
		required this.email,
		required this.businessName,
		this.token,
	});
}
