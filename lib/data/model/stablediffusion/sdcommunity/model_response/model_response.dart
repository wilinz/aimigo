import 'package:json_annotation/json_annotation.dart';

part 'model_response.g.dart';

List<SDModel> sdModelListFormJson(List json) =>
    json.map((e) => SDModel.fromJson(e as Map<String, dynamic>)).toList();

List<Map<String, dynamic>> sdModelListToJson(List<SDModel> instance) =>
    instance.map((e) => e.toJson()).toList();

@JsonSerializable(explicitToJson: true)
class SDModel {
  SDModel(
      {required this.modelId,
      required this.status,
      this.createdAt,
      this.instancePrompt,
      required this.modelName,
      required this.description,
      required this.screenshots});

  @JsonKey(name: "model_id", defaultValue: "")
  String modelId;

  @JsonKey(name: "status", defaultValue: "")
  String status;

  @JsonKey(name: "created_at")
  String? createdAt;

  @JsonKey(name: "instance_prompt")
  String? instancePrompt;

  @JsonKey(name: "model_name", defaultValue: "")
  String modelName;

  @JsonKey(name: "description", defaultValue: "")
  String description;

  @JsonKey(name: "screenshots", defaultValue: "")
  String screenshots;

  factory SDModel.fromJson(Map<String, dynamic> json) =>
      _$SDModelFromJson(json);

  Map<String, dynamic> toJson() => _$SDModelToJson(this);
}
