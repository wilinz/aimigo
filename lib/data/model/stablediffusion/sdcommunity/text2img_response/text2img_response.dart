import 'package:json_annotation/json_annotation.dart';

part 'text2img_response.g.dart';

@JsonSerializable(explicitToJson: true)
class Text2imgResponse {
  Text2imgResponse(
      {required this.status,
      required this.generationTime,
      required this.id,
      required this.output,
      required this.meta});

  @JsonKey(name: "status", defaultValue: "")
  String status;

  @JsonKey(name: "generationTime", defaultValue: 0.0)
  double generationTime;

  @JsonKey(name: "id", defaultValue: 0)
  int id;

  @JsonKey(name: "output", defaultValue: [])
  List<String> output;

  @JsonKey(name: "meta")
  Meta meta;


  factory Text2imgResponse.fromJson(Map<String, dynamic> json) => _$Text2imgResponseFromJson(json);

  Map<String, dynamic> toJson() => _$Text2imgResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Meta {
  Meta(
      {required this.prompt,
      required this.modelId,
      required this.negativePrompt,
      required this.scheduler,
      required this.safetychecker,
      required this.w,
      required this.h,
      required this.guidanceScale,
      required this.seed,
      required this.steps,
      required this.nSamples,
      required this.fullUrl,
      required this.upscale,
      required this.multiLingual,
      required this.panorama,
      required this.selfAttention,
      this.embeddings,
      this.lora,
      required this.outdir,
      required this.filePrefix});

  @JsonKey(name: "prompt", defaultValue: "")
  String prompt;

  @JsonKey(name: "model_id", defaultValue: "")
  String modelId;

  @JsonKey(name: "negative_prompt", defaultValue: "")
  String negativePrompt;

  @JsonKey(name: "scheduler", defaultValue: "")
  String scheduler;

  @JsonKey(name: "safetychecker", defaultValue: "")
  String safetychecker;

  @JsonKey(name: "W", defaultValue: 0)
  int w;

  @JsonKey(name: "H", defaultValue: 0)
  int h;

  @JsonKey(name: "guidance_scale", defaultValue: 0.0)
  double guidanceScale;

  @JsonKey(name: "seed", defaultValue: 0)
  int seed;

  @JsonKey(name: "steps", defaultValue: 0)
  int steps;

  @JsonKey(name: "n_samples", defaultValue: 0)
  int nSamples;

  @JsonKey(name: "full_url", defaultValue: "")
  String fullUrl;

  @JsonKey(name: "upscale", defaultValue: "")
  String upscale;

  @JsonKey(name: "multi_lingual", defaultValue: "")
  String multiLingual;

  @JsonKey(name: "panorama", defaultValue: "")
  String panorama;

  @JsonKey(name: "self_attention", defaultValue: "")
  String selfAttention;

  @JsonKey(name: "embeddings")
  dynamic embeddings;

  @JsonKey(name: "lora")
  dynamic lora;

  @JsonKey(name: "outdir", defaultValue: "")
  String outdir;

  @JsonKey(name: "file_prefix", defaultValue: "")
  String filePrefix;


  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}


