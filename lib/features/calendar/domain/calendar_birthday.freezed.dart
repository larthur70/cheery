// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_birthday.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarBirthday {

 String get id; String get name; String get phone;@JsonKey(name: 'template_id') String get templateId;@JsonKey(name: 'birth_date') DateTime get birthDate;@JsonKey(name: 'message_sent_year') int? get messageSentYear;@JsonKey(name: 'automatic_enabled') bool get automaticEnabled;
/// Create a copy of CalendarBirthday
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarBirthdayCopyWith<CalendarBirthday> get copyWith => _$CalendarBirthdayCopyWithImpl<CalendarBirthday>(this as CalendarBirthday, _$identity);

  /// Serializes this CalendarBirthday to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarBirthday&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.messageSentYear, messageSentYear) || other.messageSentYear == messageSentYear)&&(identical(other.automaticEnabled, automaticEnabled) || other.automaticEnabled == automaticEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,templateId,birthDate,messageSentYear,automaticEnabled);

@override
String toString() {
  return 'CalendarBirthday(id: $id, name: $name, phone: $phone, templateId: $templateId, birthDate: $birthDate, messageSentYear: $messageSentYear, automaticEnabled: $automaticEnabled)';
}


}

/// @nodoc
abstract mixin class $CalendarBirthdayCopyWith<$Res>  {
  factory $CalendarBirthdayCopyWith(CalendarBirthday value, $Res Function(CalendarBirthday) _then) = _$CalendarBirthdayCopyWithImpl;
@useResult
$Res call({
 String id, String name, String phone,@JsonKey(name: 'template_id') String templateId,@JsonKey(name: 'birth_date') DateTime birthDate,@JsonKey(name: 'message_sent_year') int? messageSentYear,@JsonKey(name: 'automatic_enabled') bool automaticEnabled
});




}
/// @nodoc
class _$CalendarBirthdayCopyWithImpl<$Res>
    implements $CalendarBirthdayCopyWith<$Res> {
  _$CalendarBirthdayCopyWithImpl(this._self, this._then);

  final CalendarBirthday _self;
  final $Res Function(CalendarBirthday) _then;

/// Create a copy of CalendarBirthday
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? templateId = null,Object? birthDate = null,Object? messageSentYear = freezed,Object? automaticEnabled = null,}) {
  return _then(CalendarBirthday(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,messageSentYear: freezed == messageSentYear ? _self.messageSentYear : messageSentYear // ignore: cast_nullable_to_non_nullable
as int?,automaticEnabled: null == automaticEnabled ? _self.automaticEnabled : automaticEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarBirthday].
extension CalendarBirthdayPatterns on CalendarBirthday {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarBirthday value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarBirthday() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarBirthday value)  $default,){
final _that = this;
switch (_that) {
case _CalendarBirthday():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarBirthday value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarBirthday() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String phone, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'birth_date')  DateTime birthDate, @JsonKey(name: 'message_sent_year')  int? messageSentYear, @JsonKey(name: 'automatic_enabled')  bool automaticEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarBirthday() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.templateId,_that.birthDate,_that.messageSentYear,_that.automaticEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String phone, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'birth_date')  DateTime birthDate, @JsonKey(name: 'message_sent_year')  int? messageSentYear, @JsonKey(name: 'automatic_enabled')  bool automaticEnabled)  $default,) {final _that = this;
switch (_that) {
case _CalendarBirthday():
return $default(_that.id,_that.name,_that.phone,_that.templateId,_that.birthDate,_that.messageSentYear,_that.automaticEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String phone, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'birth_date')  DateTime birthDate, @JsonKey(name: 'message_sent_year')  int? messageSentYear, @JsonKey(name: 'automatic_enabled')  bool automaticEnabled)?  $default,) {final _that = this;
switch (_that) {
case _CalendarBirthday() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.templateId,_that.birthDate,_that.messageSentYear,_that.automaticEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarBirthday implements CalendarBirthday {
  const _CalendarBirthday({required this.id, required this.name, required this.phone, @JsonKey(name: 'template_id') required this.templateId, @JsonKey(name: 'birth_date') required this.birthDate, @JsonKey(name: 'message_sent_year') this.messageSentYear, @JsonKey(name: 'automatic_enabled') this.automaticEnabled = false});
  factory _CalendarBirthday.fromJson(Map<String, dynamic> json) => _$CalendarBirthdayFromJson(json);

@override final  String id;
@override final  String name;
@override final  String phone;
@override@JsonKey(name: 'template_id') final  String templateId;
@override@JsonKey(name: 'birth_date') final  DateTime birthDate;
@override@JsonKey(name: 'message_sent_year') final  int? messageSentYear;
@override@JsonKey(name: 'automatic_enabled') final  bool automaticEnabled;

/// Create a copy of CalendarBirthday
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarBirthdayCopyWith<_CalendarBirthday> get copyWith => __$CalendarBirthdayCopyWithImpl<_CalendarBirthday>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarBirthdayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarBirthday&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.messageSentYear, messageSentYear) || other.messageSentYear == messageSentYear)&&(identical(other.automaticEnabled, automaticEnabled) || other.automaticEnabled == automaticEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,templateId,birthDate,messageSentYear,automaticEnabled);

@override
String toString() {
  return 'CalendarBirthday(id: $id, name: $name, phone: $phone, templateId: $templateId, birthDate: $birthDate, messageSentYear: $messageSentYear, automaticEnabled: $automaticEnabled)';
}


}

/// @nodoc
abstract mixin class _$CalendarBirthdayCopyWith<$Res> implements $CalendarBirthdayCopyWith<$Res> {
  factory _$CalendarBirthdayCopyWith(_CalendarBirthday value, $Res Function(_CalendarBirthday) _then) = __$CalendarBirthdayCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String phone,@JsonKey(name: 'template_id') String templateId,@JsonKey(name: 'birth_date') DateTime birthDate,@JsonKey(name: 'message_sent_year') int? messageSentYear,@JsonKey(name: 'automatic_enabled') bool automaticEnabled
});




}
/// @nodoc
class __$CalendarBirthdayCopyWithImpl<$Res>
    implements _$CalendarBirthdayCopyWith<$Res> {
  __$CalendarBirthdayCopyWithImpl(this._self, this._then);

  final _CalendarBirthday _self;
  final $Res Function(_CalendarBirthday) _then;

/// Create a copy of CalendarBirthday
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? templateId = null,Object? birthDate = null,Object? messageSentYear = freezed,Object? automaticEnabled = null,}) {
  return _then(_CalendarBirthday(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,messageSentYear: freezed == messageSentYear ? _self.messageSentYear : messageSentYear // ignore: cast_nullable_to_non_nullable
as int?,automaticEnabled: null == automaticEnabled ? _self.automaticEnabled : automaticEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
