import 'package:cheery/features/whatsapp_automation/domain/whatsapp_integration_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'company_name') String? companyName,
    @Default('free') String plan,
    @JsonKey(name: 'stripe_customer_id') String? stripeCustomerId,
    @JsonKey(name: 'stripe_subscription_id') String? stripeSubscriptionId,
    @JsonKey(name: 'subscription_status') String? subscriptionStatus,
    @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
    @JsonKey(name: 'notifications_enabled')
    @Default(false)
    bool notificationsEnabled,
    @JsonKey(name: 'notification_time')
    @Default('08:00:00')
    String notificationTime,
    @Default('America/Sao_Paulo') String timezone,
    @JsonKey(name: 'whatsapp_connected') @Default(false) bool whatsappConnected,
    @JsonKey(
      name: 'whatsapp_integration_status',
      fromJson: whatsAppIntegrationStatusFromJson,
      toJson: whatsAppIntegrationStatusToJson,
    )
    @Default(WhatsAppIntegrationStatus.disconnected)
    WhatsAppIntegrationStatus whatsappIntegrationStatus,
    @JsonKey(name: 'whatsapp_phone_number_id') String? whatsappPhoneNumberId,
    @JsonKey(name: 'whatsapp_business_account_id')
    String? whatsappBusinessAccountId,
    @JsonKey(name: 'whatsapp_display_phone') String? whatsappDisplayPhone,
    @JsonKey(name: 'whatsapp_connected_at') DateTime? whatsappConnectedAt,
    @JsonKey(name: 'whatsapp_last_error') String? whatsappLastError,
    @JsonKey(name: 'onboarding_completed')
    @Default(false)
    bool onboardingCompleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

extension ProfilePlanX on Profile {
  bool get isPro => plan == 'pro';
  bool get isFree => !isPro;

  bool get hasCompanyName => companyName?.trim().isNotEmpty == true;

  bool get isWhatsAppReady =>
      isPro &&
      whatsappConnected &&
      whatsappIntegrationStatus.isConnected;
}
