// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SDModel _$SDModelFromJson(Map<String, dynamic> json) => SDModel(
      modelId: json['model_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      instancePrompt: json['instance_prompt'] as String?,
      modelName: json['model_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      screenshots: json['screenshots'] as String? ?? '',
    );

Map<String, dynamic> _$SDModelToJson(SDModel instance) => <String, dynamic>{
      'model_id': instance.modelId,
      'status': instance.status,
      'created_at': instance.createdAt,
      'instance_prompt': instance.instancePrompt,
      'model_name': instance.modelName,
      'description': instance.description,
      'screenshots': instance.screenshots,
    };
