// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Template {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name;/// Meta-format body with `{{1}}`, `{{2}}`, …
 String get message;/// Ordered variable keys matching Meta placeholder indices.
 List<String> get variables;@JsonKey(name: 'is_default') bool get isDefault;@JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) TemplateApprovalStatus get approvalStatus;@JsonKey(name: 'meta_template_name') String? get metaTemplateName;@JsonKey(name: 'meta_template_id') String? get metaTemplateId;@JsonKey(name: 'submitted_at') DateTime? get submittedAt;@JsonKey(name: 'approved_at') DateTime? get approvedAt;@JsonKey(name: 'rejected_reason') String? get rejectedReason;@JsonKey(name: 'meta_category') String get metaCategory;@JsonKey(name: 'meta_language') String get metaLanguage;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Template
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateCopyWith<Template> get copyWith => _$TemplateCopyWithImpl<Template>(this as Template, _$identity);

  /// Serializes this Template to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Template&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.variables, variables)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.approvalStatus, approvalStatus) || other.approvalStatus == approvalStatus)&&(identical(other.metaTemplateName, metaTemplateName) || other.metaTemplateName == metaTemplateName)&&(identical(other.metaTemplateId, metaTemplateId) || other.metaTemplateId == metaTemplateId)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.rejectedReason, rejectedReason) || other.rejectedReason == rejectedReason)&&(identical(other.metaCategory, metaCategory) || other.metaCategory == metaCategory)&&(identical(other.metaLanguage, metaLanguage) || other.metaLanguage == metaLanguage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,message,const DeepCollectionEquality().hash(variables),isDefault,approvalStatus,metaTemplateName,metaTemplateId,submittedAt,approvedAt,rejectedReason,metaCategory,metaLanguage,createdAt,updatedAt);

@override
String toString() {
  return 'Template(id: $id, userId: $userId, name: $name, message: $message, variables: $variables, isDefault: $isDefault, approvalStatus: $approvalStatus, metaTemplateName: $metaTemplateName, metaTemplateId: $metaTemplateId, submittedAt: $submittedAt, approvedAt: $approvedAt, rejectedReason: $rejectedReason, metaCategory: $metaCategory, metaLanguage: $metaLanguage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TemplateCopyWith<$Res>  {
  factory $TemplateCopyWith(Template value, $Res Function(Template) _then) = _$TemplateCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String message, List<String> variables,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) TemplateApprovalStatus approvalStatus,@JsonKey(name: 'meta_template_name') String? metaTemplateName,@JsonKey(name: 'meta_template_id') String? metaTemplateId,@JsonKey(name: 'submitted_at') DateTime? submittedAt,@JsonKey(name: 'approved_at') DateTime? approvedAt,@JsonKey(name: 'rejected_reason') String? rejectedReason,@JsonKey(name: 'meta_category') String metaCategory,@JsonKey(name: 'meta_language') String metaLanguage,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$TemplateCopyWithImpl<$Res>
    implements $TemplateCopyWith<$Res> {
  _$TemplateCopyWithImpl(this._self, this._then);

  final Template _self;
  final $Res Function(Template) _then;

/// Create a copy of Template
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? message = null,Object? variables = null,Object? isDefault = null,Object? approvalStatus = null,Object? metaTemplateName = freezed,Object? metaTemplateId = freezed,Object? submittedAt = freezed,Object? approvedAt = freezed,Object? rejectedReason = freezed,Object? metaCategory = null,Object? metaLanguage = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Template(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,variables: null == variables ? _self.variables : variables // ignore: cast_nullable_to_non_nullable
as List<String>,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,approvalStatus: null == approvalStatus ? _self.approvalStatus : approvalStatus // ignore: cast_nullable_to_non_nullable
as TemplateApprovalStatus,metaTemplateName: freezed == metaTemplateName ? _self.metaTemplateName : metaTemplateName // ignore: cast_nullable_to_non_nullable
as String?,metaTemplateId: freezed == metaTemplateId ? _self.metaTemplateId : metaTemplateId // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectedReason: freezed == rejectedReason ? _self.rejectedReason : rejectedReason // ignore: cast_nullable_to_non_nullable
as String?,metaCategory: null == metaCategory ? _self.metaCategory : metaCategory // ignore: cast_nullable_to_non_nullable
as String,metaLanguage: null == metaLanguage ? _self.metaLanguage : metaLanguage // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Template].
extension TemplatePatterns on Template {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Template value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Template() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Template value)  $default,){
final _that = this;
switch (_that) {
case _Template():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Template value)?  $default,){
final _that = this;
switch (_that) {
case _Template() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String message,  List<String> variables, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson)  TemplateApprovalStatus approvalStatus, @JsonKey(name: 'meta_template_name')  String? metaTemplateName, @JsonKey(name: 'meta_template_id')  String? metaTemplateId, @JsonKey(name: 'submitted_at')  DateTime? submittedAt, @JsonKey(name: 'approved_at')  DateTime? approvedAt, @JsonKey(name: 'rejected_reason')  String? rejectedReason, @JsonKey(name: 'meta_category')  String metaCategory, @JsonKey(name: 'meta_language')  String metaLanguage, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Template() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.message,_that.variables,_that.isDefault,_that.approvalStatus,_that.metaTemplateName,_that.metaTemplateId,_that.submittedAt,_that.approvedAt,_that.rejectedReason,_that.metaCategory,_that.metaLanguage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String message,  List<String> variables, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson)  TemplateApprovalStatus approvalStatus, @JsonKey(name: 'meta_template_name')  String? metaTemplateName, @JsonKey(name: 'meta_template_id')  String? metaTemplateId, @JsonKey(name: 'submitted_at')  DateTime? submittedAt, @JsonKey(name: 'approved_at')  DateTime? approvedAt, @JsonKey(name: 'rejected_reason')  String? rejectedReason, @JsonKey(name: 'meta_category')  String metaCategory, @JsonKey(name: 'meta_language')  String metaLanguage, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Template():
return $default(_that.id,_that.userId,_that.name,_that.message,_that.variables,_that.isDefault,_that.approvalStatus,_that.metaTemplateName,_that.metaTemplateId,_that.submittedAt,_that.approvedAt,_that.rejectedReason,_that.metaCategory,_that.metaLanguage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String message,  List<String> variables, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson)  TemplateApprovalStatus approvalStatus, @JsonKey(name: 'meta_template_name')  String? metaTemplateName, @JsonKey(name: 'meta_template_id')  String? metaTemplateId, @JsonKey(name: 'submitted_at')  DateTime? submittedAt, @JsonKey(name: 'approved_at')  DateTime? approvedAt, @JsonKey(name: 'rejected_reason')  String? rejectedReason, @JsonKey(name: 'meta_category')  String metaCategory, @JsonKey(name: 'meta_language')  String metaLanguage, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Template() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.message,_that.variables,_that.isDefault,_that.approvalStatus,_that.metaTemplateName,_that.metaTemplateId,_that.submittedAt,_that.approvedAt,_that.rejectedReason,_that.metaCategory,_that.metaLanguage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Template implements Template {
  const _Template({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, required this.message,  List<String> variables = const [], @JsonKey(name: 'is_default') this.isDefault = false, @JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) this.approvalStatus = TemplateApprovalStatus.draft, @JsonKey(name: 'meta_template_name') this.metaTemplateName, @JsonKey(name: 'meta_template_id') this.metaTemplateId, @JsonKey(name: 'submitted_at') this.submittedAt, @JsonKey(name: 'approved_at') this.approvedAt, @JsonKey(name: 'rejected_reason') this.rejectedReason, @JsonKey(name: 'meta_category') this.metaCategory = 'UTILITY', @JsonKey(name: 'meta_language') this.metaLanguage = 'pt_BR', @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _variables = variables;
  factory _Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
/// Meta-format body with `{{1}}`, `{{2}}`, …
@override final  String message;
/// Ordered variable keys matching Meta placeholder indices.
 final  List<String> _variables;
/// Ordered variable keys matching Meta placeholder indices.
@override@JsonKey() List<String> get variables {
  if (_variables is EqualUnmodifiableListView) return _variables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_variables);
}

@override@JsonKey(name: 'is_default') final  bool isDefault;
@override@JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) final  TemplateApprovalStatus approvalStatus;
@override@JsonKey(name: 'meta_template_name') final  String? metaTemplateName;
@override@JsonKey(name: 'meta_template_id') final  String? metaTemplateId;
@override@JsonKey(name: 'submitted_at') final  DateTime? submittedAt;
@override@JsonKey(name: 'approved_at') final  DateTime? approvedAt;
@override@JsonKey(name: 'rejected_reason') final  String? rejectedReason;
@override@JsonKey(name: 'meta_category') final  String metaCategory;
@override@JsonKey(name: 'meta_language') final  String metaLanguage;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Template
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateCopyWith<_Template> get copyWith => __$TemplateCopyWithImpl<_Template>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Template&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._variables, _variables)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.approvalStatus, approvalStatus) || other.approvalStatus == approvalStatus)&&(identical(other.metaTemplateName, metaTemplateName) || other.metaTemplateName == metaTemplateName)&&(identical(other.metaTemplateId, metaTemplateId) || other.metaTemplateId == metaTemplateId)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.rejectedReason, rejectedReason) || other.rejectedReason == rejectedReason)&&(identical(other.metaCategory, metaCategory) || other.metaCategory == metaCategory)&&(identical(other.metaLanguage, metaLanguage) || other.metaLanguage == metaLanguage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,message,const DeepCollectionEquality().hash(_variables),isDefault,approvalStatus,metaTemplateName,metaTemplateId,submittedAt,approvedAt,rejectedReason,metaCategory,metaLanguage,createdAt,updatedAt);

@override
String toString() {
  return 'Template(id: $id, userId: $userId, name: $name, message: $message, variables: $variables, isDefault: $isDefault, approvalStatus: $approvalStatus, metaTemplateName: $metaTemplateName, metaTemplateId: $metaTemplateId, submittedAt: $submittedAt, approvedAt: $approvedAt, rejectedReason: $rejectedReason, metaCategory: $metaCategory, metaLanguage: $metaLanguage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TemplateCopyWith<$Res> implements $TemplateCopyWith<$Res> {
  factory _$TemplateCopyWith(_Template value, $Res Function(_Template) _then) = __$TemplateCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String message, List<String> variables,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) TemplateApprovalStatus approvalStatus,@JsonKey(name: 'meta_template_name') String? metaTemplateName,@JsonKey(name: 'meta_template_id') String? metaTemplateId,@JsonKey(name: 'submitted_at') DateTime? submittedAt,@JsonKey(name: 'approved_at') DateTime? approvedAt,@JsonKey(name: 'rejected_reason') String? rejectedReason,@JsonKey(name: 'meta_category') String metaCategory,@JsonKey(name: 'meta_language') String metaLanguage,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$TemplateCopyWithImpl<$Res>
    implements _$TemplateCopyWith<$Res> {
  __$TemplateCopyWithImpl(this._self, this._then);

  final _Template _self;
  final $Res Function(_Template) _then;

/// Create a copy of Template
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? message = null,Object? variables = null,Object? isDefault = null,Object? approvalStatus = null,Object? metaTemplateName = freezed,Object? metaTemplateId = freezed,Object? submittedAt = freezed,Object? approvedAt = freezed,Object? rejectedReason = freezed,Object? metaCategory = null,Object? metaLanguage = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Template(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,variables: null == variables ? _self._variables : variables // ignore: cast_nullable_to_non_nullable
as List<String>,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,approvalStatus: null == approvalStatus ? _self.approvalStatus : approvalStatus // ignore: cast_nullable_to_non_nullable
as TemplateApprovalStatus,metaTemplateName: freezed == metaTemplateName ? _self.metaTemplateName : metaTemplateName // ignore: cast_nullable_to_non_nullable
as String?,metaTemplateId: freezed == metaTemplateId ? _self.metaTemplateId : metaTemplateId // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectedReason: freezed == rejectedReason ? _self.rejectedReason : rejectedReason // ignore: cast_nullable_to_non_nullable
as String?,metaCategory: null == metaCategory ? _self.metaCategory : metaCategory // ignore: cast_nullable_to_non_nullable
as String,metaLanguage: null == metaLanguage ? _self.metaLanguage : metaLanguage // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
