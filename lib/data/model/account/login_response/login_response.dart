import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginResponse {
  LoginResponse(
      {required this.code,
      required this.msg,
      this.data});

  @JsonKey(name: "code", defaultValue: 0)
  int code;

  @JsonKey(name: "msg", defaultValue: "")
  String msg;

  @JsonKey(name: "data")
  dynamic data;


  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}


