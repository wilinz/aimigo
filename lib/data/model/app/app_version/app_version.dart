import 'package:dart_extensions/dart_extensions.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app_version.g.dart';

@JsonSerializable(explicitToJson: true)
class AppVersionResponse {
  AppVersionResponse(
      {required this.code,
      required this.data,
      required this.msg});

  @JsonKey(name: "code", defaultValue: 0)
  int code;

  @JsonKey(name: "data")
  AppVersion data;

  @JsonKey(name: "msg", defaultValue: "")
  String msg;


  factory AppVersionResponse.fromJson(Map<String, dynamic> json) => _$AppVersionFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AppVersion {
  AppVersion(
      {required this.appName,
      required this.appid,
      required this.canHide,
      required this.changelog,
      required this.createdAt,
      required this.downloadUrl,
      required this.isForce,
      required this.updatedAt,
      required this.versionCode,
      required this.versionName});

  @JsonKey(name: "app_name", defaultValue: "")
  String appName;

  @JsonKey(name: "appid", defaultValue: "")
  String appid;

  @JsonKey(name: "can_hide", defaultValue: false)
  bool canHide;

  @JsonKey(name: "changelog", defaultValue: "")
  String changelog;

  @JsonKey(name: "created_at", defaultValue: 0)
  int createdAt;

  @JsonKey(name: "download_url", defaultValue: "")
  String downloadUrl;

  @JsonKey(name: "is_force", defaultValue: false)
  bool isForce;

  @JsonKey(name: "updated_at", defaultValue: 0)
  int updatedAt;

  @JsonKey(name: "version_code", defaultValue: 0)
  int versionCode;

  @JsonKey(name: "version_name", defaultValue: "")
  String versionName;


  factory AppVersion.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);

  bool isHasNewVersion(PackageInfo info){
    return (
        this.versionCode >
            (info.buildNumber.toIntOrNull() ?? -1));
  }
}


