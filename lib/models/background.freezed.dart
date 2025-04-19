// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'background.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Background _$BackgroundFromJson(Map<String, dynamic> json) {
  return _Background.fromJson(json);
}

/// @nodoc
mixin _$Background {
  /// Unique identifier for the background
  String get id => throw _privateConstructorUsedError;

  /// Name of the background (e.g., "Noble", "Merchant")
  String get name => throw _privateConstructorUsedError;

  /// Detailed description of the background
  String get description => throw _privateConstructorUsedError;

  /// Character's place of birth
  String get placeOfBirth => throw _privateConstructorUsedError;

  /// Description of character's parents
  String get parents => throw _privateConstructorUsedError;

  /// Description of character's siblings
  String get siblings => throw _privateConstructorUsedError;

  /// ID of the template this background is based on (null if completely custom)
  String? get templateId => throw _privateConstructorUsedError;

  /// Whether this background has been customized from its template
  bool get isCustomized => throw _privateConstructorUsedError;

  /// Serializes this Background to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Background
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackgroundCopyWith<Background> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackgroundCopyWith<$Res> {
  factory $BackgroundCopyWith(
          Background value, $Res Function(Background) then) =
      _$BackgroundCopyWithImpl<$Res, Background>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String placeOfBirth,
      String parents,
      String siblings,
      String? templateId,
      bool isCustomized});
}

/// @nodoc
class _$BackgroundCopyWithImpl<$Res, $Val extends Background>
    implements $BackgroundCopyWith<$Res> {
  _$BackgroundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Background
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? placeOfBirth = null,
    Object? parents = null,
    Object? siblings = null,
    Object? templateId = freezed,
    Object? isCustomized = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      placeOfBirth: null == placeOfBirth
          ? _value.placeOfBirth
          : placeOfBirth // ignore: cast_nullable_to_non_nullable
              as String,
      parents: null == parents
          ? _value.parents
          : parents // ignore: cast_nullable_to_non_nullable
              as String,
      siblings: null == siblings
          ? _value.siblings
          : siblings // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      isCustomized: null == isCustomized
          ? _value.isCustomized
          : isCustomized // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BackgroundImplCopyWith<$Res>
    implements $BackgroundCopyWith<$Res> {
  factory _$$BackgroundImplCopyWith(
          _$BackgroundImpl value, $Res Function(_$BackgroundImpl) then) =
      __$$BackgroundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String placeOfBirth,
      String parents,
      String siblings,
      String? templateId,
      bool isCustomized});
}

/// @nodoc
class __$$BackgroundImplCopyWithImpl<$Res>
    extends _$BackgroundCopyWithImpl<$Res, _$BackgroundImpl>
    implements _$$BackgroundImplCopyWith<$Res> {
  __$$BackgroundImplCopyWithImpl(
      _$BackgroundImpl _value, $Res Function(_$BackgroundImpl) _then)
      : super(_value, _then);

  /// Create a copy of Background
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? placeOfBirth = null,
    Object? parents = null,
    Object? siblings = null,
    Object? templateId = freezed,
    Object? isCustomized = null,
  }) {
    return _then(_$BackgroundImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      placeOfBirth: null == placeOfBirth
          ? _value.placeOfBirth
          : placeOfBirth // ignore: cast_nullable_to_non_nullable
              as String,
      parents: null == parents
          ? _value.parents
          : parents // ignore: cast_nullable_to_non_nullable
              as String,
      siblings: null == siblings
          ? _value.siblings
          : siblings // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      isCustomized: null == isCustomized
          ? _value.isCustomized
          : isCustomized // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BackgroundImpl extends _Background with DiagnosticableTreeMixin {
  const _$BackgroundImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.placeOfBirth,
      required this.parents,
      required this.siblings,
      this.templateId,
      this.isCustomized = false})
      : super._();

  factory _$BackgroundImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackgroundImplFromJson(json);

  /// Unique identifier for the background
  @override
  final String id;

  /// Name of the background (e.g., "Noble", "Merchant")
  @override
  final String name;

  /// Detailed description of the background
  @override
  final String description;

  /// Character's place of birth
  @override
  final String placeOfBirth;

  /// Description of character's parents
  @override
  final String parents;

  /// Description of character's siblings
  @override
  final String siblings;

  /// ID of the template this background is based on (null if completely custom)
  @override
  final String? templateId;

  /// Whether this background has been customized from its template
  @override
  @JsonKey()
  final bool isCustomized;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Background(id: $id, name: $name, description: $description, placeOfBirth: $placeOfBirth, parents: $parents, siblings: $siblings, templateId: $templateId, isCustomized: $isCustomized)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Background'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('placeOfBirth', placeOfBirth))
      ..add(DiagnosticsProperty('parents', parents))
      ..add(DiagnosticsProperty('siblings', siblings))
      ..add(DiagnosticsProperty('templateId', templateId))
      ..add(DiagnosticsProperty('isCustomized', isCustomized));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackgroundImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.placeOfBirth, placeOfBirth) ||
                other.placeOfBirth == placeOfBirth) &&
            (identical(other.parents, parents) || other.parents == parents) &&
            (identical(other.siblings, siblings) ||
                other.siblings == siblings) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.isCustomized, isCustomized) ||
                other.isCustomized == isCustomized));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description,
      placeOfBirth, parents, siblings, templateId, isCustomized);

  /// Create a copy of Background
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackgroundImplCopyWith<_$BackgroundImpl> get copyWith =>
      __$$BackgroundImplCopyWithImpl<_$BackgroundImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackgroundImplToJson(
      this,
    );
  }
}

abstract class _Background extends Background {
  const factory _Background(
      {required final String id,
      required final String name,
      required final String description,
      required final String placeOfBirth,
      required final String parents,
      required final String siblings,
      final String? templateId,
      final bool isCustomized}) = _$BackgroundImpl;
  const _Background._() : super._();

  factory _Background.fromJson(Map<String, dynamic> json) =
      _$BackgroundImpl.fromJson;

  /// Unique identifier for the background
  @override
  String get id;

  /// Name of the background (e.g., "Noble", "Merchant")
  @override
  String get name;

  /// Detailed description of the background
  @override
  String get description;

  /// Character's place of birth
  @override
  String get placeOfBirth;

  /// Description of character's parents
  @override
  String get parents;

  /// Description of character's siblings
  @override
  String get siblings;

  /// ID of the template this background is based on (null if completely custom)
  @override
  String? get templateId;

  /// Whether this background has been customized from its template
  @override
  bool get isCustomized;

  /// Create a copy of Background
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackgroundImplCopyWith<_$BackgroundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
