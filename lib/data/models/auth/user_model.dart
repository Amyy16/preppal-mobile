import 'package:json_annotation/json_annotation.dart';

// This tells the generator: "look for user_model.g.dart"
part 'user_model.g.dart';

/// @JsonSerializable() annotation enables automatic JSON serialization/deserialization
/// Run `dart run build_runner build` to generate the serialization code
@JsonSerializable()
class UserModel {
  /// Unique identifier for the user
  final String id;

  /// Username chosen by the user
  final String username;

  /// Email address of the user
  final String email;

  /// Business name associated with the user's account
  @JsonKey(name: 'business_name')
  final String businessName;

  /// Authentication token for API requests (nullable)
  final String? token;

  /// Constructor with all required fields
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.businessName,
    this.token,
  });

  /// [Factory constructor]: creates a UserModel FROM a JSON map
  /// The '_$UserModelFromJson' function is auto-generated in user_model.g.dart
  /// Used when parsing API responses into UserModel objects
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts this UserModel TO a JSON map
  /// The '_$UserModelToJson' function is also auto-generated
  /// Used when sending data to the API or storing locally
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

