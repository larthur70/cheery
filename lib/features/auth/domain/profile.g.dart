// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  fullName: json['full_name'] as String?,
  companyName: json['company_name'] as String?,
  plan: json['plan'] as String? ?? 'free',
  stripeCustomerId: json['stripe_customer_id'] as String?,
  stripeSubscriptionId: json['stripe_subscription_id'] as String?,
  subscriptionStatus: json['subscription_status'] as String?,
  currentPeriodEnd: json['current_period_end'] == null
      ? null
      : DateTime.parse(json['current_period_end'] as String),
  notificationsEnabled: json['notifications_enabled'] as bool? ?? false,
  notificationTime: json['notification_time'] as String? ?? '08:00:00',
  timezone: json['timezone'] as String? ?? 'America/Sao_Paulo',
  whatsappConnected: json['whatsapp_connected'] as bool? ?? false,
  whatsappIntegrationStatus: json['whatsapp_integration_status'] == null
      ? WhatsAppIntegrationStatus.disconnected
      : whatsAppIntegrationStatusFromJson(json['whatsapp_integration_status']),
  whatsappPhoneNumberId: json['whatsapp_phone_number_id'] as String?,
  whatsappBusinessAccountId: json['whatsapp_business_account_id'] as String?,
  whatsappDisplayPhone: json['whatsapp_display_phone'] as String?,
  whatsappConnectedAt: json['whatsapp_connected_at'] == null
      ? null
      : DateTime.parse(json['whatsapp_connected_at'] as String),
  whatsappLastError: json['whatsapp_last_error'] as String?,
  onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'company_name': instance.companyName,
  'plan': instance.plan,
  'stripe_customer_id': instance.stripeCustomerId,
  'stripe_subscription_id': instance.stripeSubscriptionId,
  'subscription_status': instance.subscriptionStatus,
  'current_period_end': instance.currentPeriodEnd?.toIso8601String(),
  'notifications_enabled': instance.notificationsEnabled,
  'notification_time': instance.notificationTime,
  'timezone': instance.timezone,
  'whatsapp_connected': instance.whatsappConnected,
  'whatsapp_integration_status': whatsAppIntegrationStatusToJson(
    instance.whatsappIntegrationStatus,
  ),
  'whatsapp_phone_number_id': instance.whatsappPhoneNumberId,
  'whatsapp_business_account_id': instance.whatsappBusinessAccountId,
  'whatsapp_display_phone': instance.whatsappDisplayPhone,
  'whatsapp_connected_at': instance.whatsappConnectedAt?.toIso8601String(),
  'whatsapp_last_error': instance.whatsappLastError,
  'onboarding_completed': instance.onboardingCompleted,
  'created_at': instance.createdAt.toIso8601String(),
};
