// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReminderSettings {

@JsonKey(name: 'notifications_enabled') bool get notificationsEnabled;/// Postgres `time` as `HH:mm:ss` (or `HH:mm`).
@JsonKey(name: 'notification_time') String get notificationTime; String get timezone;
/// Create a copy of ReminderSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderSettingsCopyWith<ReminderSettings> get copyWith => _$ReminderSettingsCopyWithImpl<ReminderSettings>(this as ReminderSettings, _$identity);

  /// Serializes this ReminderSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReminderSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.notificationTime, notificationTime) || other.notificationTime == notificationTime)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,notificationTime,timezone);

@override
String toString() {
  return 'ReminderSettings(notificationsEnabled: $notificationsEnabled, notificationTime: $notificationTime, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class $ReminderSettingsCopyWith<$Res>  {
  factory $ReminderSettingsCopyWith(ReminderSettings value, $Res Function(ReminderSettings) _then) = _$ReminderSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'notifications_enabled') bool notificationsEnabled,@JsonKey(name: 'notification_time') String notificationTime, String timezone
});




}
/// @nodoc
class _$ReminderSettingsCopyWithImpl<$Res>
    implements $ReminderSettingsCopyWith<$Res> {
  _$ReminderSettingsCopyWithImpl(this._self, this._then);

  final ReminderSettings _self;
  final $Res Function(ReminderSettings) _then;

/// Create a copy of ReminderSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notificationsEnabled = null,Object? notificationTime = null,Object? timezone = null,}) {
  return _then(ReminderSettings(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notificationTime: null == notificationTime ? _self.notificationTime : notificationTime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReminderSettings].
extension ReminderSettingsPatterns on ReminderSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReminderSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReminderSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReminderSettings value)  $default,){
final _that = this;
switch (_that) {
case _ReminderSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReminderSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ReminderSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'notification_time')  String notificationTime,  String timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReminderSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.notificationTime,_that.timezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'notification_time')  String notificationTime,  String timezone)  $default,) {final _that = this;
switch (_that) {
case _ReminderSettings():
return $default(_that.notificationsEnabled,_that.notificationTime,_that.timezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'notification_time')  String notificationTime,  String timezone)?  $default,) {final _that = this;
switch (_that) {
case _ReminderSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.notificationTime,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReminderSettings implements ReminderSettings {
  const _ReminderSettings({@JsonKey(name: 'notifications_enabled') this.notificationsEnabled = false, @JsonKey(name: 'notification_time') this.notificationTime = '08:00:00', this.timezone = 'America/Sao_Paulo'});
  factory _ReminderSettings.fromJson(Map<String, dynamic> json) => _$ReminderSettingsFromJson(json);

@override@JsonKey(name: 'notifications_enabled') final  bool notificationsEnabled;
/// Postgres `time` as `HH:mm:ss` (or `HH:mm`).
@override@JsonKey(name: 'notification_time') final  String notificationTime;
@override@JsonKey() final  String timezone;

/// Create a copy of ReminderSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderSettingsCopyWith<_ReminderSettings> get copyWith => __$ReminderSettingsCopyWithImpl<_ReminderSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReminderSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReminderSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.notificationTime, notificationTime) || other.notificationTime == notificationTime)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,notificationTime,timezone);

@override
String toString() {
  return 'ReminderSettings(notificationsEnabled: $notificationsEnabled, notificationTime: $notificationTime, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$ReminderSettingsCopyWith<$Res> implements $ReminderSettingsCopyWith<$Res> {
  factory _$ReminderSettingsCopyWith(_ReminderSettings value, $Res Function(_ReminderSettings) _then) = __$ReminderSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'notifications_enabled') bool notificationsEnabled,@JsonKey(name: 'notification_time') String notificationTime, String timezone
});




}
/// @nodoc
class __$ReminderSettingsCopyWithImpl<$Res>
    implements _$ReminderSettingsCopyWith<$Res> {
  __$ReminderSettingsCopyWithImpl(this._self, this._then);

  final _ReminderSettings _self;
  final $Res Function(_ReminderSettings) _then;

/// Create a copy of ReminderSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notificationsEnabled = null,Object? notificationTime = null,Object? timezone = null,}) {
  return _then(_ReminderSettings(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notificationTime: null == notificationTime ? _self.notificationTime : notificationTime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
