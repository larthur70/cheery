// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get id;@JsonKey(name: 'full_name') String? get fullName;@JsonKey(name: 'company_name') String? get companyName; String get plan;@JsonKey(name: 'stripe_customer_id') String? get stripeCustomerId;@JsonKey(name: 'stripe_subscription_id') String? get stripeSubscriptionId;@JsonKey(name: 'subscription_status') String? get subscriptionStatus;@JsonKey(name: 'current_period_end') DateTime? get currentPeriodEnd;@JsonKey(name: 'notifications_enabled') bool get notificationsEnabled;@JsonKey(name: 'notification_time') String get notificationTime; String get timezone;@JsonKey(name: 'whatsapp_connected') bool get whatsappConnected;@JsonKey(name: 'whatsapp_integration_status', fromJson: whatsAppIntegrationStatusFromJson, toJson: whatsAppIntegrationStatusToJson) WhatsAppIntegrationStatus get whatsappIntegrationStatus;@JsonKey(name: 'whatsapp_phone_number_id') String? get whatsappPhoneNumberId;@JsonKey(name: 'whatsapp_business_account_id') String? get whatsappBusinessAccountId;@JsonKey(name: 'whatsapp_display_phone') String? get whatsappDisplayPhone;@JsonKey(name: 'whatsapp_connected_at') DateTime? get whatsappConnectedAt;@JsonKey(name: 'whatsapp_last_error') String? get whatsappLastError;@JsonKey(name: 'onboarding_completed') bool get onboardingCompleted;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripeSubscriptionId, stripeSubscriptionId) || other.stripeSubscriptionId == stripeSubscriptionId)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.notificationTime, notificationTime) || other.notificationTime == notificationTime)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.whatsappConnected, whatsappConnected) || other.whatsappConnected == whatsappConnected)&&(identical(other.whatsappIntegrationStatus, whatsappIntegrationStatus) || other.whatsappIntegrationStatus == whatsappIntegrationStatus)&&(identical(other.whatsappPhoneNumberId, whatsappPhoneNumberId) || other.whatsappPhoneNumberId == whatsappPhoneNumberId)&&(identical(other.whatsappBusinessAccountId, whatsappBusinessAccountId) || other.whatsappBusinessAccountId == whatsappBusinessAccountId)&&(identical(other.whatsappDisplayPhone, whatsappDisplayPhone) || other.whatsappDisplayPhone == whatsappDisplayPhone)&&(identical(other.whatsappConnectedAt, whatsappConnectedAt) || other.whatsappConnectedAt == whatsappConnectedAt)&&(identical(other.whatsappLastError, whatsappLastError) || other.whatsappLastError == whatsappLastError)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,fullName,companyName,plan,stripeCustomerId,stripeSubscriptionId,subscriptionStatus,currentPeriodEnd,notificationsEnabled,notificationTime,timezone,whatsappConnected,whatsappIntegrationStatus,whatsappPhoneNumberId,whatsappBusinessAccountId,whatsappDisplayPhone,whatsappConnectedAt,whatsappLastError,onboardingCompleted,createdAt]);

@override
String toString() {
  return 'Profile(id: $id, fullName: $fullName, companyName: $companyName, plan: $plan, stripeCustomerId: $stripeCustomerId, stripeSubscriptionId: $stripeSubscriptionId, subscriptionStatus: $subscriptionStatus, currentPeriodEnd: $currentPeriodEnd, notificationsEnabled: $notificationsEnabled, notificationTime: $notificationTime, timezone: $timezone, whatsappConnected: $whatsappConnected, whatsappIntegrationStatus: $whatsappIntegrationStatus, whatsappPhoneNumberId: $whatsappPhoneNumberId, whatsappBusinessAccountId: $whatsappBusinessAccountId, whatsappDisplayPhone: $whatsappDisplayPhone, whatsappConnectedAt: $whatsappConnectedAt, whatsappLastError: $whatsappLastError, onboardingCompleted: $onboardingCompleted, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String? fullName,@JsonKey(name: 'company_name') String? companyName, String plan,@JsonKey(name: 'stripe_customer_id') String? stripeCustomerId,@JsonKey(name: 'stripe_subscription_id') String? stripeSubscriptionId,@JsonKey(name: 'subscription_status') String? subscriptionStatus,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,@JsonKey(name: 'notifications_enabled') bool notificationsEnabled,@JsonKey(name: 'notification_time') String notificationTime, String timezone,@JsonKey(name: 'whatsapp_connected') bool whatsappConnected,@JsonKey(name: 'whatsapp_integration_status', fromJson: whatsAppIntegrationStatusFromJson, toJson: whatsAppIntegrationStatusToJson) WhatsAppIntegrationStatus whatsappIntegrationStatus,@JsonKey(name: 'whatsapp_phone_number_id') String? whatsappPhoneNumberId,@JsonKey(name: 'whatsapp_business_account_id') String? whatsappBusinessAccountId,@JsonKey(name: 'whatsapp_display_phone') String? whatsappDisplayPhone,@JsonKey(name: 'whatsapp_connected_at') DateTime? whatsappConnectedAt,@JsonKey(name: 'whatsapp_last_error') String? whatsappLastError,@JsonKey(name: 'onboarding_completed') bool onboardingCompleted,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = freezed,Object? companyName = freezed,Object? plan = null,Object? stripeCustomerId = freezed,Object? stripeSubscriptionId = freezed,Object? subscriptionStatus = freezed,Object? currentPeriodEnd = freezed,Object? notificationsEnabled = null,Object? notificationTime = null,Object? timezone = null,Object? whatsappConnected = null,Object? whatsappIntegrationStatus = null,Object? whatsappPhoneNumberId = freezed,Object? whatsappBusinessAccountId = freezed,Object? whatsappDisplayPhone = freezed,Object? whatsappConnectedAt = freezed,Object? whatsappLastError = freezed,Object? onboardingCompleted = null,Object? createdAt = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,stripeSubscriptionId: freezed == stripeSubscriptionId ? _self.stripeSubscriptionId : stripeSubscriptionId // ignore: cast_nullable_to_non_nullable
as String?,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notificationTime: null == notificationTime ? _self.notificationTime : notificationTime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,whatsappConnected: null == whatsappConnected ? _self.whatsappConnected : whatsappConnected // ignore: cast_nullable_to_non_nullable
as bool,whatsappIntegrationStatus: null == whatsappIntegrationStatus ? _self.whatsappIntegrationStatus : whatsappIntegrationStatus // ignore: cast_nullable_to_non_nullable
as WhatsAppIntegrationStatus,whatsappPhoneNumberId: freezed == whatsappPhoneNumberId ? _self.whatsappPhoneNumberId : whatsappPhoneNumberId // ignore: cast_nullable_to_non_nullable
as String?,whatsappBusinessAccountId: freezed == whatsappBusinessAccountId ? _self.whatsappBusinessAccountId : whatsappBusinessAccountId // ignore: cast_nullable_to_non_nullable
as String?,whatsappDisplayPhone: freezed == whatsappDisplayPhone ? _self.whatsappDisplayPhone : whatsappDisplayPhone // ignore: cast_nullable_to_non_nullable
as String?,whatsappConnectedAt: freezed == whatsappConnectedAt ? _self.whatsappConnectedAt : whatsappConnectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,whatsappLastError: freezed == whatsappLastError ? _self.whatsappLastError : whatsappLastError // ignore: cast_nullable_to_non_nullable
as String?,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'company_name')  String? companyName,  String plan, @JsonKey(name: 'stripe_customer_id')  String? stripeCustomerId, @JsonKey(name: 'stripe_subscription_id')  String? stripeSubscriptionId, @JsonKey(name: 'subscription_status')  String? subscriptionStatus, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'notification_time')  String notificationTime,  String timezone, @JsonKey(name: 'whatsapp_connected')  bool whatsappConnected, @JsonKey(name: 'whatsapp_integration_status', fromJson: whatsAppIntegrationStatusFromJson, toJson: whatsAppIntegrationStatusToJson)  WhatsAppIntegrationStatus whatsappIntegrationStatus, @JsonKey(name: 'whatsapp_phone_number_id')  String? whatsappPhoneNumberId, @JsonKey(name: 'whatsapp_business_account_id')  String? whatsappBusinessAccountId, @JsonKey(name: 'whatsapp_display_phone')  String? whatsappDisplayPhone, @JsonKey(name: 'whatsapp_connected_at')  DateTime? whatsappConnectedAt, @JsonKey(name: 'whatsapp_last_error')  String? whatsappLastError, @JsonKey(name: 'onboarding_completed')  bool onboardingCompleted, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.fullName,_that.companyName,_that.plan,_that.stripeCustomerId,_that.stripeSubscriptionId,_that.subscriptionStatus,_that.currentPeriodEnd,_that.notificationsEnabled,_that.notificationTime,_that.timezone,_that.whatsappConnected,_that.whatsappIntegrationStatus,_that.whatsappPhoneNumberId,_that.whatsappBusinessAccountId,_that.whatsappDisplayPhone,_that.whatsappConnectedAt,_that.whatsappLastError,_that.onboardingCompleted,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'company_name')  String? companyName,  String plan, @JsonKey(name: 'stripe_customer_id')  String? stripeCustomerId, @JsonKey(name: 'stripe_subscription_id')  String? stripeSubscriptionId, @JsonKey(name: 'subscription_status')  String? subscriptionStatus, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'notification_time')  String notificationTime,  String timezone, @JsonKey(name: 'whatsapp_connected')  bool whatsappConnected, @JsonKey(name: 'whatsapp_integration_status', fromJson: whatsAppIntegrationStatusFromJson, toJson: whatsAppIntegrationStatusToJson)  WhatsAppIntegrationStatus whatsappIntegrationStatus, @JsonKey(name: 'whatsapp_phone_number_id')  String? whatsappPhoneNumberId, @JsonKey(name: 'whatsapp_business_account_id')  String? whatsappBusinessAccountId, @JsonKey(name: 'whatsapp_display_phone')  String? whatsappDisplayPhone, @JsonKey(name: 'whatsapp_connected_at')  DateTime? whatsappConnectedAt, @JsonKey(name: 'whatsapp_last_error')  String? whatsappLastError, @JsonKey(name: 'onboarding_completed')  bool onboardingCompleted, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.fullName,_that.companyName,_that.plan,_that.stripeCustomerId,_that.stripeSubscriptionId,_that.subscriptionStatus,_that.currentPeriodEnd,_that.notificationsEnabled,_that.notificationTime,_that.timezone,_that.whatsappConnected,_that.whatsappIntegrationStatus,_that.whatsappPhoneNumberId,_that.whatsappBusinessAccountId,_that.whatsappDisplayPhone,_that.whatsappConnectedAt,_that.whatsappLastError,_that.onboardingCompleted,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'company_name')  String? companyName,  String plan, @JsonKey(name: 'stripe_customer_id')  String? stripeCustomerId, @JsonKey(name: 'stripe_subscription_id')  String? stripeSubscriptionId, @JsonKey(name: 'subscription_status')  String? subscriptionStatus, @JsonKey(name: 'current_period_end')  DateTime? currentPeriodEnd, @JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'notification_time')  String notificationTime,  String timezone, @JsonKey(name: 'whatsapp_connected')  bool whatsappConnected, @JsonKey(name: 'whatsapp_integration_status', fromJson: whatsAppIntegrationStatusFromJson, toJson: whatsAppIntegrationStatusToJson)  WhatsAppIntegrationStatus whatsappIntegrationStatus, @JsonKey(name: 'whatsapp_phone_number_id')  String? whatsappPhoneNumberId, @JsonKey(name: 'whatsapp_business_account_id')  String? whatsappBusinessAccountId, @JsonKey(name: 'whatsapp_display_phone')  String? whatsappDisplayPhone, @JsonKey(name: 'whatsapp_connected_at')  DateTime? whatsappConnectedAt, @JsonKey(name: 'whatsapp_last_error')  String? whatsappLastError, @JsonKey(name: 'onboarding_completed')  bool onboardingCompleted, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.fullName,_that.companyName,_that.plan,_that.stripeCustomerId,_that.stripeSubscriptionId,_that.subscriptionStatus,_that.currentPeriodEnd,_that.notificationsEnabled,_that.notificationTime,_that.timezone,_that.whatsappConnected,_that.whatsappIntegrationStatus,_that.whatsappPhoneNumberId,_that.whatsappBusinessAccountId,_that.whatsappDisplayPhone,_that.whatsappConnectedAt,_that.whatsappLastError,_that.onboardingCompleted,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, @JsonKey(name: 'full_name') this.fullName, @JsonKey(name: 'company_name') this.companyName, this.plan = 'free', @JsonKey(name: 'stripe_customer_id') this.stripeCustomerId, @JsonKey(name: 'stripe_subscription_id') this.stripeSubscriptionId, @JsonKey(name: 'subscription_status') this.subscriptionStatus, @JsonKey(name: 'current_period_end') this.currentPeriodEnd, @JsonKey(name: 'notifications_enabled') this.notificationsEnabled = false, @JsonKey(name: 'notification_time') this.notificationTime = '08:00:00', this.timezone = 'America/Sao_Paulo', @JsonKey(name: 'whatsapp_connected') this.whatsappConnected = false, @JsonKey(name: 'whatsapp_integration_status', fromJson: whatsAppIntegrationStatusFromJson, toJson: whatsAppIntegrationStatusToJson) this.whatsappIntegrationStatus = WhatsAppIntegrationStatus.disconnected, @JsonKey(name: 'whatsapp_phone_number_id') this.whatsappPhoneNumberId, @JsonKey(name: 'whatsapp_business_account_id') this.whatsappBusinessAccountId, @JsonKey(name: 'whatsapp_display_phone') this.whatsappDisplayPhone, @JsonKey(name: 'whatsapp_connected_at') this.whatsappConnectedAt, @JsonKey(name: 'whatsapp_last_error') this.whatsappLastError, @JsonKey(name: 'onboarding_completed') this.onboardingCompleted = false, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String? fullName;
@override@JsonKey(name: 'company_name') final  String? companyName;
@override@JsonKey() final  String plan;
@override@JsonKey(name: 'stripe_customer_id') final  String? stripeCustomerId;
@override@JsonKey(name: 'stripe_subscription_id') final  String? stripeSubscriptionId;
@override@JsonKey(name: 'subscription_status') final  String? subscriptionStatus;
@override@JsonKey(name: 'current_period_end') final  DateTime? currentPeriodEnd;
@override@JsonKey(name: 'notifications_enabled') final  bool notificationsEnabled;
@override@JsonKey(name: 'notification_time') final  String notificationTime;
@override@JsonKey() final  String timezone;
@override@JsonKey(name: 'whatsapp_connected') final  bool whatsappConnected;
@override@JsonKey(name: 'whatsapp_integration_status', fromJson: whatsAppIntegrationStatusFromJson, toJson: whatsAppIntegrationStatusToJson) final  WhatsAppIntegrationStatus whatsappIntegrationStatus;
@override@JsonKey(name: 'whatsapp_phone_number_id') final  String? whatsappPhoneNumberId;
@override@JsonKey(name: 'whatsapp_business_account_id') final  String? whatsappBusinessAccountId;
@override@JsonKey(name: 'whatsapp_display_phone') final  String? whatsappDisplayPhone;
@override@JsonKey(name: 'whatsapp_connected_at') final  DateTime? whatsappConnectedAt;
@override@JsonKey(name: 'whatsapp_last_error') final  String? whatsappLastError;
@override@JsonKey(name: 'onboarding_completed') final  bool onboardingCompleted;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripeSubscriptionId, stripeSubscriptionId) || other.stripeSubscriptionId == stripeSubscriptionId)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.notificationTime, notificationTime) || other.notificationTime == notificationTime)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.whatsappConnected, whatsappConnected) || other.whatsappConnected == whatsappConnected)&&(identical(other.whatsappIntegrationStatus, whatsappIntegrationStatus) || other.whatsappIntegrationStatus == whatsappIntegrationStatus)&&(identical(other.whatsappPhoneNumberId, whatsappPhoneNumberId) || other.whatsappPhoneNumberId == whatsappPhoneNumberId)&&(identical(other.whatsappBusinessAccountId, whatsappBusinessAccountId) || other.whatsappBusinessAccountId == whatsappBusinessAccountId)&&(identical(other.whatsappDisplayPhone, whatsappDisplayPhone) || other.whatsappDisplayPhone == whatsappDisplayPhone)&&(identical(other.whatsappConnectedAt, whatsappConnectedAt) || other.whatsappConnectedAt == whatsappConnectedAt)&&(identical(other.whatsappLastError, whatsappLastError) || other.whatsappLastError == whatsappLastError)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,fullName,companyName,plan,stripeCustomerId,stripeSubscriptionId,subscriptionStatus,currentPeriodEnd,notificationsEnabled,notificationTime,timezone,whatsappConnected,whatsappIntegrationStatus,whatsappPhoneNumberId,whatsappBusinessAccountId,whatsappDisplayPhone,whatsappConnectedAt,whatsappLastError,onboardingCompleted,createdAt]);

@override
String toString() {
  return 'Profile(id: $id, fullName: $fullName, companyName: $companyName, plan: $plan, stripeCustomerId: $stripeCustomerId, stripeSubscriptionId: $stripeSubscriptionId, subscriptionStatus: $subscriptionStatus, currentPeriodEnd: $currentPeriodEnd, notificationsEnabled: $notificationsEnabled, notificationTime: $notificationTime, timezone: $timezone, whatsappConnected: $whatsappConnected, whatsappIntegrationStatus: $whatsappIntegrationStatus, whatsappPhoneNumberId: $whatsappPhoneNumberId, whatsappBusinessAccountId: $whatsappBusinessAccountId, whatsappDisplayPhone: $whatsappDisplayPhone, whatsappConnectedAt: $whatsappConnectedAt, whatsappLastError: $whatsappLastError, onboardingCompleted: $onboardingCompleted, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String? fullName,@JsonKey(name: 'company_name') String? companyName, String plan,@JsonKey(name: 'stripe_customer_id') String? stripeCustomerId,@JsonKey(name: 'stripe_subscription_id') String? stripeSubscriptionId,@JsonKey(name: 'subscription_status') String? subscriptionStatus,@JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,@JsonKey(name: 'notifications_enabled') bool notificationsEnabled,@JsonKey(name: 'notification_time') String notificationTime, String timezone,@JsonKey(name: 'whatsapp_connected') bool whatsappConnected,@JsonKey(name: 'whatsapp_integration_status', fromJson: whatsAppIntegrationStatusFromJson, toJson: whatsAppIntegrationStatusToJson) WhatsAppIntegrationStatus whatsappIntegrationStatus,@JsonKey(name: 'whatsapp_phone_number_id') String? whatsappPhoneNumberId,@JsonKey(name: 'whatsapp_business_account_id') String? whatsappBusinessAccountId,@JsonKey(name: 'whatsapp_display_phone') String? whatsappDisplayPhone,@JsonKey(name: 'whatsapp_connected_at') DateTime? whatsappConnectedAt,@JsonKey(name: 'whatsapp_last_error') String? whatsappLastError,@JsonKey(name: 'onboarding_completed') bool onboardingCompleted,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = freezed,Object? companyName = freezed,Object? plan = null,Object? stripeCustomerId = freezed,Object? stripeSubscriptionId = freezed,Object? subscriptionStatus = freezed,Object? currentPeriodEnd = freezed,Object? notificationsEnabled = null,Object? notificationTime = null,Object? timezone = null,Object? whatsappConnected = null,Object? whatsappIntegrationStatus = null,Object? whatsappPhoneNumberId = freezed,Object? whatsappBusinessAccountId = freezed,Object? whatsappDisplayPhone = freezed,Object? whatsappConnectedAt = freezed,Object? whatsappLastError = freezed,Object? onboardingCompleted = null,Object? createdAt = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,stripeSubscriptionId: freezed == stripeSubscriptionId ? _self.stripeSubscriptionId : stripeSubscriptionId // ignore: cast_nullable_to_non_nullable
as String?,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String?,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notificationTime: null == notificationTime ? _self.notificationTime : notificationTime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,whatsappConnected: null == whatsappConnected ? _self.whatsappConnected : whatsappConnected // ignore: cast_nullable_to_non_nullable
as bool,whatsappIntegrationStatus: null == whatsappIntegrationStatus ? _self.whatsappIntegrationStatus : whatsappIntegrationStatus // ignore: cast_nullable_to_non_nullable
as WhatsAppIntegrationStatus,whatsappPhoneNumberId: freezed == whatsappPhoneNumberId ? _self.whatsappPhoneNumberId : whatsappPhoneNumberId // ignore: cast_nullable_to_non_nullable
as String?,whatsappBusinessAccountId: freezed == whatsappBusinessAccountId ? _self.whatsappBusinessAccountId : whatsappBusinessAccountId // ignore: cast_nullable_to_non_nullable
as String?,whatsappDisplayPhone: freezed == whatsappDisplayPhone ? _self.whatsappDisplayPhone : whatsappDisplayPhone // ignore: cast_nullable_to_non_nullable
as String?,whatsappConnectedAt: freezed == whatsappConnectedAt ? _self.whatsappConnectedAt : whatsappConnectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,whatsappLastError: freezed == whatsappLastError ? _self.whatsappLastError : whatsappLastError // ignore: cast_nullable_to_non_nullable
as String?,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
