import 'package:json_annotation/json_annotation.dart';
import 'package:prepal2/domain/entities/user_entity.dart';

// This tells the generator: "look for user_model.g.dart"
part 'user_model.g.dart';

/// @JsonSerializable() annotation enables automatic JSON serialization/deserialization
/// Run `dart run build_runner build` to generate the serialization code
@JsonSerializable()
class UserModel extends UserEntity {
  /// @JsonKey lets you map JSON field names to Dart field names
  /// e.g. if API returns "business_name" but we want "businessName" in Dart
  /// Use @override to indicate this field overrides the parent class field
  @JsonKey(name: 'business_name')
  @override
  final String businessName;

  /// Constructor with required parameters
  /// Uses super() to pass values to parent UserEntity class
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required this.businessName,
    super.token,
  }) : super(businessName: businessName);

  /// [Factory constructor]: creates a UserModel FROM a JSON map
  /// The '_$UserModelFromJson' function is auto-generated in user_model.g.dart
  /// Used when parsing API responses into UserModel objects
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts this UserModel TO a JSON map
  /// The '_$UserModelToJson' function is also auto-generated
  /// Used when sending data to the API or storing locally
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// [Helper Factory]: Convert a domain Entity into a Model (useful when saving data)
  /// Bridges the gap between domain layer entities and data layer models
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      businessName: entity.businessName,
      token: entity.token,
    );
  }
}
