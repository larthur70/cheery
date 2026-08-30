// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Client {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name; String get phone;@JsonKey(name: 'birth_date') DateTime get birthDate;@JsonKey(name: 'template_id') String get templateId;@JsonKey(name: 'template_name') String? get templateName;/// Calendar year the birthday WhatsApp was marked sent; null = not sent.
@JsonKey(name: 'message_sent_year') int? get messageSentYear;@JsonKey(name: 'automatic_enabled') bool get automaticEnabled;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientCopyWith<Client> get copyWith => _$ClientCopyWithImpl<Client>(this as Client, _$identity);

  /// Serializes this Client to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Client&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.messageSentYear, messageSentYear) || other.messageSentYear == messageSentYear)&&(identical(other.automaticEnabled, automaticEnabled) || other.automaticEnabled == automaticEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,phone,birthDate,templateId,templateName,messageSentYear,automaticEnabled,createdAt,updatedAt);

@override
String toString() {
  return 'Client(id: $id, userId: $userId, name: $name, phone: $phone, birthDate: $birthDate, templateId: $templateId, templateName: $templateName, messageSentYear: $messageSentYear, automaticEnabled: $automaticEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClientCopyWith<$Res>  {
  factory $ClientCopyWith(Client value, $Res Function(Client) _then) = _$ClientCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String phone,@JsonKey(name: 'birth_date') DateTime birthDate,@JsonKey(name: 'template_id') String templateId,@JsonKey(name: 'template_name') String? templateName,@JsonKey(name: 'message_sent_year') int? messageSentYear,@JsonKey(name: 'automatic_enabled') bool automaticEnabled,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ClientCopyWithImpl<$Res>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._self, this._then);

  final Client _self;
  final $Res Function(Client) _then;

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? phone = null,Object? birthDate = null,Object? templateId = null,Object? templateName = freezed,Object? messageSentYear = freezed,Object? automaticEnabled = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Client(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,messageSentYear: freezed == messageSentYear ? _self.messageSentYear : messageSentYear // ignore: cast_nullable_to_non_nullable
as int?,automaticEnabled: null == automaticEnabled ? _self.automaticEnabled : automaticEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Client].
extension ClientPatterns on Client {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Client value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Client() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Client value)  $default,){
final _that = this;
switch (_that) {
case _Client():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Client value)?  $default,){
final _that = this;
switch (_that) {
case _Client() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String phone, @JsonKey(name: 'birth_date')  DateTime birthDate, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_name')  String? templateName, @JsonKey(name: 'message_sent_year')  int? messageSentYear, @JsonKey(name: 'automatic_enabled')  bool automaticEnabled, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Client() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.phone,_that.birthDate,_that.templateId,_that.templateName,_that.messageSentYear,_that.automaticEnabled,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String phone, @JsonKey(name: 'birth_date')  DateTime birthDate, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_name')  String? templateName, @JsonKey(name: 'message_sent_year')  int? messageSentYear, @JsonKey(name: 'automatic_enabled')  bool automaticEnabled, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Client():
return $default(_that.id,_that.userId,_that.name,_that.phone,_that.birthDate,_that.templateId,_that.templateName,_that.messageSentYear,_that.automaticEnabled,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String phone, @JsonKey(name: 'birth_date')  DateTime birthDate, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_name')  String? templateName, @JsonKey(name: 'message_sent_year')  int? messageSentYear, @JsonKey(name: 'automatic_enabled')  bool automaticEnabled, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Client() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.phone,_that.birthDate,_that.templateId,_that.templateName,_that.messageSentYear,_that.automaticEnabled,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Client implements Client {
  const _Client({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, required this.phone, @JsonKey(name: 'birth_date') required this.birthDate, @JsonKey(name: 'template_id') required this.templateId, @JsonKey(name: 'template_name') this.templateName, @JsonKey(name: 'message_sent_year') this.messageSentYear, @JsonKey(name: 'automatic_enabled') this.automaticEnabled = false, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override final  String phone;
@override@JsonKey(name: 'birth_date') final  DateTime birthDate;
@override@JsonKey(name: 'template_id') final  String templateId;
@override@JsonKey(name: 'template_name') final  String? templateName;
/// Calendar year the birthday WhatsApp was marked sent; null = not sent.
@override@JsonKey(name: 'message_sent_year') final  int? messageSentYear;
@override@JsonKey(name: 'automatic_enabled') final  bool automaticEnabled;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientCopyWith<_Client> get copyWith => __$ClientCopyWithImpl<_Client>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Client&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.messageSentYear, messageSentYear) || other.messageSentYear == messageSentYear)&&(identical(other.automaticEnabled, automaticEnabled) || other.automaticEnabled == automaticEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,phone,birthDate,templateId,templateName,messageSentYear,automaticEnabled,createdAt,updatedAt);

@override
String toString() {
  return 'Client(id: $id, userId: $userId, name: $name, phone: $phone, birthDate: $birthDate, templateId: $templateId, templateName: $templateName, messageSentYear: $messageSentYear, automaticEnabled: $automaticEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClientCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$ClientCopyWith(_Client value, $Res Function(_Client) _then) = __$ClientCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String phone,@JsonKey(name: 'birth_date') DateTime birthDate,@JsonKey(name: 'template_id') String templateId,@JsonKey(name: 'template_name') String? templateName,@JsonKey(name: 'message_sent_year') int? messageSentYear,@JsonKey(name: 'automatic_enabled') bool automaticEnabled,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ClientCopyWithImpl<$Res>
    implements _$ClientCopyWith<$Res> {
  __$ClientCopyWithImpl(this._self, this._then);

  final _Client _self;
  final $Res Function(_Client) _then;

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? phone = null,Object? birthDate = null,Object? templateId = null,Object? templateName = freezed,Object? messageSentYear = freezed,Object? automaticEnabled = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Client(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,messageSentYear: freezed == messageSentYear ? _self.messageSentYear : messageSentYear // ignore: cast_nullable_to_non_nullable
as int?,automaticEnabled: null == automaticEnabled ? _self.automaticEnabled : automaticEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
