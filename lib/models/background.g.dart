// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackgroundImpl _$$BackgroundImplFromJson(Map<String, dynamic> json) =>
    _$BackgroundImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      placeOfBirth: json['placeOfBirth'] as String,
      parents: json['parents'] as String,
      siblings: json['siblings'] as String,
      templateId: json['templateId'] as String?,
      isCustomized: json['isCustomized'] as bool? ?? false,
    );

Map<String, dynamic> _$$BackgroundImplToJson(_$BackgroundImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'placeOfBirth': instance.placeOfBirth,
      'parents': instance.parents,
      'siblings': instance.siblings,
      'templateId': instance.templateId,
      'isCustomized': instance.isCustomized,
    };
