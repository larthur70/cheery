// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whatsapp_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WhatsAppConnection {

 bool get connected; WhatsAppIntegrationStatus get status; String? get displayPhone; DateTime? get connectedAt; String? get lastError;
/// Create a copy of WhatsAppConnection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhatsAppConnectionCopyWith<WhatsAppConnection> get copyWith => _$WhatsAppConnectionCopyWithImpl<WhatsAppConnection>(this as WhatsAppConnection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhatsAppConnection&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.status, status) || other.status == status)&&(identical(other.displayPhone, displayPhone) || other.displayPhone == displayPhone)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode => Object.hash(runtimeType,connected,status,displayPhone,connectedAt,lastError);

@override
String toString() {
  return 'WhatsAppConnection(connected: $connected, status: $status, displayPhone: $displayPhone, connectedAt: $connectedAt, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class $WhatsAppConnectionCopyWith<$Res>  {
  factory $WhatsAppConnectionCopyWith(WhatsAppConnection value, $Res Function(WhatsAppConnection) _then) = _$WhatsAppConnectionCopyWithImpl;
@useResult
$Res call({
 bool connected, WhatsAppIntegrationStatus status, String? displayPhone, DateTime? connectedAt, String? lastError
});




}
/// @nodoc
class _$WhatsAppConnectionCopyWithImpl<$Res>
    implements $WhatsAppConnectionCopyWith<$Res> {
  _$WhatsAppConnectionCopyWithImpl(this._self, this._then);

  final WhatsAppConnection _self;
  final $Res Function(WhatsAppConnection) _then;

/// Create a copy of WhatsAppConnection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? connected = null,Object? status = null,Object? displayPhone = freezed,Object? connectedAt = freezed,Object? lastError = freezed,}) {
  return _then(WhatsAppConnection(
connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WhatsAppIntegrationStatus,displayPhone: freezed == displayPhone ? _self.displayPhone : displayPhone // ignore: cast_nullable_to_non_nullable
as String?,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WhatsAppConnection].
extension WhatsAppConnectionPatterns on WhatsAppConnection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WhatsAppConnection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WhatsAppConnection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WhatsAppConnection value)  $default,){
final _that = this;
switch (_that) {
case _WhatsAppConnection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WhatsAppConnection value)?  $default,){
final _that = this;
switch (_that) {
case _WhatsAppConnection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool connected,  WhatsAppIntegrationStatus status,  String? displayPhone,  DateTime? connectedAt,  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WhatsAppConnection() when $default != null:
return $default(_that.connected,_that.status,_that.displayPhone,_that.connectedAt,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool connected,  WhatsAppIntegrationStatus status,  String? displayPhone,  DateTime? connectedAt,  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _WhatsAppConnection():
return $default(_that.connected,_that.status,_that.displayPhone,_that.connectedAt,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool connected,  WhatsAppIntegrationStatus status,  String? displayPhone,  DateTime? connectedAt,  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _WhatsAppConnection() when $default != null:
return $default(_that.connected,_that.status,_that.displayPhone,_that.connectedAt,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc


class _WhatsAppConnection extends WhatsAppConnection {
  const _WhatsAppConnection({this.connected = false, this.status = WhatsAppIntegrationStatus.disconnected, this.displayPhone, this.connectedAt, this.lastError}): super._();
  

@override@JsonKey() final  bool connected;
@override@JsonKey() final  WhatsAppIntegrationStatus status;
@override final  String? displayPhone;
@override final  DateTime? connectedAt;
@override final  String? lastError;

/// Create a copy of WhatsAppConnection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WhatsAppConnectionCopyWith<_WhatsAppConnection> get copyWith => __$WhatsAppConnectionCopyWithImpl<_WhatsAppConnection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WhatsAppConnection&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.status, status) || other.status == status)&&(identical(other.displayPhone, displayPhone) || other.displayPhone == displayPhone)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode => Object.hash(runtimeType,connected,status,displayPhone,connectedAt,lastError);

@override
String toString() {
  return 'WhatsAppConnection(connected: $connected, status: $status, displayPhone: $displayPhone, connectedAt: $connectedAt, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$WhatsAppConnectionCopyWith<$Res> implements $WhatsAppConnectionCopyWith<$Res> {
  factory _$WhatsAppConnectionCopyWith(_WhatsAppConnection value, $Res Function(_WhatsAppConnection) _then) = __$WhatsAppConnectionCopyWithImpl;
@override @useResult
$Res call({
 bool connected, WhatsAppIntegrationStatus status, String? displayPhone, DateTime? connectedAt, String? lastError
});




}
/// @nodoc
class __$WhatsAppConnectionCopyWithImpl<$Res>
    implements _$WhatsAppConnectionCopyWith<$Res> {
  __$WhatsAppConnectionCopyWithImpl(this._self, this._then);

  final _WhatsAppConnection _self;
  final $Res Function(_WhatsAppConnection) _then;

/// Create a copy of WhatsAppConnection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? connected = null,Object? status = null,Object? displayPhone = freezed,Object? connectedAt = freezed,Object? lastError = freezed,}) {
  return _then(_WhatsAppConnection(
connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WhatsAppIntegrationStatus,displayPhone: freezed == displayPhone ? _self.displayPhone : displayPhone // ignore: cast_nullable_to_non_nullable
as String?,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
