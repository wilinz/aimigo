// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionResponse _$AppVersionFromJson(Map<String, dynamic> json) => AppVersionResponse(
      code: json['code'] as int? ?? 0,
      data: AppVersion.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String? ?? '',
    );

Map<String, dynamic> _$AppVersionToJson(AppVersionResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data.toJson(),
      'msg': instance.msg,
    };

AppVersion _$DataFromJson(Map<String, dynamic> json) => AppVersion(
      appName: json['app_name'] as String? ?? '',
      appid: json['appid'] as String? ?? '',
      canHide: json['can_hide'] as bool? ?? false,
      changelog: json['changelog'] as String? ?? '',
      createdAt: json['created_at'] as int? ?? 0,
      downloadUrl: json['download_url'] as String? ?? '',
      isForce: json['is_force'] as bool? ?? false,
      updatedAt: json['updated_at'] as int? ?? 0,
      versionCode: json['version_code'] as int? ?? 0,
      versionName: json['version_name'] as String? ?? '',
    );

Map<String, dynamic> _$DataToJson(AppVersion instance) => <String, dynamic>{
      'app_name': instance.appName,
      'appid': instance.appid,
      'can_hide': instance.canHide,
      'changelog': instance.changelog,
      'created_at': instance.createdAt,
      'download_url': instance.downloadUrl,
      'is_force': instance.isForce,
      'updated_at': instance.updatedAt,
      'version_code': instance.versionCode,
      'version_name': instance.versionName,
    };
