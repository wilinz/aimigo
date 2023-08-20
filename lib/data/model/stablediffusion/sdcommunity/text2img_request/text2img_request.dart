import 'package:json_annotation/json_annotation.dart';

part 'text2img_request.g.dart';

@JsonSerializable(explicitToJson: true)
class Text2imgRequest {
  Text2imgRequest(
      {required this.key,
      required this.modelId,
      required this.prompt,
      required this.negativePrompt,
      required this.width,
      required this.height,
      required this.samples,
      required this.numInferenceSteps,
      required this.safetyChecker,
      required this.enhancePrompt,
      this.seed,
      required this.guidanceScale,
      required this.multiLingual,
      required this.panorama,
      required this.selfAttention,
      required this.upscale,
      this.embeddingsModel,
      this.loraModel,
      required this.tomesd,
      required this.clipSkip,
      required this.useKarrasSigmas,
      this.vae,
      this.loraStrength,
      required this.scheduler,
      this.webhook,
      this.trackId});

  @JsonKey(name: "key", defaultValue: "")
  String key;

  @JsonKey(name: "model_id", defaultValue: "")
  String modelId;

  @JsonKey(name: "prompt", defaultValue: "")
  String prompt;

  @JsonKey(name: "negative_prompt", defaultValue: "")
  String negativePrompt;

  @JsonKey(name: "width", defaultValue: "")
  String width;

  @JsonKey(name: "height", defaultValue: "")
  String height;

  @JsonKey(name: "samples", defaultValue: "")
  String samples;

  @JsonKey(name: "num_inference_steps", defaultValue: "")
  String numInferenceSteps;

  /// A checker for NSFW images. If such an image is detected, it will be replaced by a blank image.
  /// safety_checker_type	Modify image if NSFW images are found; default: sensitive_content_text, options: blur/sensitive_content_text/pixelate/black
  @JsonKey(name: "safety_checker", defaultValue: "")
  String safetyChecker;

  @JsonKey(name: "enhance_prompt", defaultValue: "")
  String enhancePrompt;

  @JsonKey(name: "seed")
  int? seed;

  /// guidance_scale	Scale for classifier-free guidance (minimum: 1; maximum: 20)
  /// guidance_scale 是一种增加对指导生成（在本例中为文本）以及总体样本质量的条件信号的依从性的方法。
  /// 它也被称为无分类器引导，简单地说，调整它可以更好的使用图像质量更好或更具备多样性。
  /// 值介于7和8.5之间通常是稳定扩散的好选择。默认情况下，guidance_scale为7.5。
  /// 如果值很大， 图像质量可能更好，但对应的多样性会降低
  /// 如果值很小， 图像质量可能更差，但对应的多样性会增加
  @JsonKey(name: "guidance_scale", defaultValue: 0.0)
  double guidanceScale;

  /// Allow multi lingual prompt to generate images. Set this to "yes" if you use a language different from English in your text prompts.
  @JsonKey(name: "multi_lingual", defaultValue: "")
  String multiLingual;

  /// Set this parameter to "yes" to generate a panorama image.
  @JsonKey(name: "panorama", defaultValue: "")
  String panorama;

  /// If you want a high quality image, set this parameter to "yes". In this case the image generation will take more time.
  @JsonKey(name: "self_attention", defaultValue: "")
  String selfAttention;

  /// Set this parameter to "2" if you want to upscale the given image resolution two times (2x), options:: 1, 2, 3
  @JsonKey(name: "upscale", defaultValue: "")
  String upscale;

  @JsonKey(name: "embeddings_model")
  String? embeddingsModel;

  @JsonKey(name: "lora_model")
  String? loraModel;

  /// Enable tomesd to generate images: gives really fast results, default: yes, options: yes/no
  @JsonKey(name: "tomesd", defaultValue: "")
  String tomesd;

  /// Clip Skip (minimum: 1; maximum: 8)
  @JsonKey(name: "clip_skip", defaultValue: "")
  String clipSkip;

  /// Use keras sigmas to generate images. gives nice results, default: yes, options: yes/no
  @JsonKey(name: "use_karras_sigmas", defaultValue: "")
  String useKarrasSigmas;

  @JsonKey(name: "vae")
  dynamic vae;

  @JsonKey(name: "lora_strength")
  String? loraStrength;

  /// DDPMScheduler
  /// DDIMScheduler
  /// PNDMScheduler
  /// LMSDiscreteScheduler
  /// EulerDiscreteScheduler
  /// EulerAncestralDiscreteScheduler
  /// DPMSolverMultistepScheduler
  /// HeunDiscreteScheduler
  /// KDPM2DiscreteScheduler
  /// DPMSolverSinglestepScheduler
  /// KDPM2AncestralDiscreteScheduler
  /// UniPCMultistepScheduler
  /// DDIMInverseScheduler
  /// DEISMultistepScheduler
  /// IPNDMScheduler
  /// KarrasVeScheduler
  /// ScoreSdeVeScheduler
  @JsonKey(name: "scheduler", defaultValue: "")
  String scheduler;

  @JsonKey(name: "webhook")
  String? webhook;

  @JsonKey(name: "track_id")
  String? trackId;


  factory Text2imgRequest.fromJson(Map<String, dynamic> json) => _$Text2imgRequestFromJson(json);

  Map<String, dynamic> toJson() => _$Text2imgRequestToJson(this);
}


