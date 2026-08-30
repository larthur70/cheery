// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateSummary {

 String get id; String get name;@JsonKey(name: 'is_default') bool get isDefault;@JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) TemplateApprovalStatus get approvalStatus;
/// Create a copy of TemplateSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateSummaryCopyWith<TemplateSummary> get copyWith => _$TemplateSummaryCopyWithImpl<TemplateSummary>(this as TemplateSummary, _$identity);

  /// Serializes this TemplateSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.approvalStatus, approvalStatus) || other.approvalStatus == approvalStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isDefault,approvalStatus);

@override
String toString() {
  return 'TemplateSummary(id: $id, name: $name, isDefault: $isDefault, approvalStatus: $approvalStatus)';
}


}

/// @nodoc
abstract mixin class $TemplateSummaryCopyWith<$Res>  {
  factory $TemplateSummaryCopyWith(TemplateSummary value, $Res Function(TemplateSummary) _then) = _$TemplateSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) TemplateApprovalStatus approvalStatus
});




}
/// @nodoc
class _$TemplateSummaryCopyWithImpl<$Res>
    implements $TemplateSummaryCopyWith<$Res> {
  _$TemplateSummaryCopyWithImpl(this._self, this._then);

  final TemplateSummary _self;
  final $Res Function(TemplateSummary) _then;

/// Create a copy of TemplateSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isDefault = null,Object? approvalStatus = null,}) {
  return _then(TemplateSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,approvalStatus: null == approvalStatus ? _self.approvalStatus : approvalStatus // ignore: cast_nullable_to_non_nullable
as TemplateApprovalStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateSummary].
extension TemplateSummaryPatterns on TemplateSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateSummary value)  $default,){
final _that = this;
switch (_that) {
case _TemplateSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson)  TemplateApprovalStatus approvalStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateSummary() when $default != null:
return $default(_that.id,_that.name,_that.isDefault,_that.approvalStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson)  TemplateApprovalStatus approvalStatus)  $default,) {final _that = this;
switch (_that) {
case _TemplateSummary():
return $default(_that.id,_that.name,_that.isDefault,_that.approvalStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson)  TemplateApprovalStatus approvalStatus)?  $default,) {final _that = this;
switch (_that) {
case _TemplateSummary() when $default != null:
return $default(_that.id,_that.name,_that.isDefault,_that.approvalStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateSummary implements TemplateSummary {
  const _TemplateSummary({required this.id, required this.name, @JsonKey(name: 'is_default') this.isDefault = false, @JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) this.approvalStatus = TemplateApprovalStatus.draft});
  factory _TemplateSummary.fromJson(Map<String, dynamic> json) => _$TemplateSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'is_default') final  bool isDefault;
@override@JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) final  TemplateApprovalStatus approvalStatus;

/// Create a copy of TemplateSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateSummaryCopyWith<_TemplateSummary> get copyWith => __$TemplateSummaryCopyWithImpl<_TemplateSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.approvalStatus, approvalStatus) || other.approvalStatus == approvalStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isDefault,approvalStatus);

@override
String toString() {
  return 'TemplateSummary(id: $id, name: $name, isDefault: $isDefault, approvalStatus: $approvalStatus)';
}


}

/// @nodoc
abstract mixin class _$TemplateSummaryCopyWith<$Res> implements $TemplateSummaryCopyWith<$Res> {
  factory _$TemplateSummaryCopyWith(_TemplateSummary value, $Res Function(_TemplateSummary) _then) = __$TemplateSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'approval_status', fromJson: templateApprovalStatusFromJson, toJson: templateApprovalStatusToJson) TemplateApprovalStatus approvalStatus
});




}
/// @nodoc
class __$TemplateSummaryCopyWithImpl<$Res>
    implements _$TemplateSummaryCopyWith<$Res> {
  __$TemplateSummaryCopyWithImpl(this._self, this._then);

  final _TemplateSummary _self;
  final $Res Function(_TemplateSummary) _then;

/// Create a copy of TemplateSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isDefault = null,Object? approvalStatus = null,}) {
  return _then(_TemplateSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,approvalStatus: null == approvalStatus ? _self.approvalStatus : approvalStatus // ignore: cast_nullable_to_non_nullable
as TemplateApprovalStatus,
  ));
}


}

// dart format on
