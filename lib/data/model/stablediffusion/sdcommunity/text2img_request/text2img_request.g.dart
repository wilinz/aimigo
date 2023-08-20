// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text2img_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Text2imgRequest _$Text2imgRequestFromJson(Map<String, dynamic> json) =>
    Text2imgRequest(
      key: json['key'] as String? ?? '',
      modelId: json['model_id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      negativePrompt: json['negative_prompt'] as String? ?? '',
      width: json['width'] as String? ?? '',
      height: json['height'] as String? ?? '',
      samples: json['samples'] as String? ?? '',
      numInferenceSteps: json['num_inference_steps'] as String? ?? '',
      safetyChecker: json['safety_checker'] as String? ?? '',
      enhancePrompt: json['enhance_prompt'] as String? ?? '',
      seed: json['seed'] as int?,
      guidanceScale: (json['guidance_scale'] as num?)?.toDouble() ?? 0.0,
      multiLingual: json['multi_lingual'] as String? ?? '',
      panorama: json['panorama'] as String? ?? '',
      selfAttention: json['self_attention'] as String? ?? '',
      upscale: json['upscale'] as String? ?? '',
      embeddingsModel: json['embeddings_model'] as String?,
      loraModel: json['lora_model'] as String?,
      tomesd: json['tomesd'] as String? ?? '',
      clipSkip: json['clip_skip'] as String? ?? '',
      useKarrasSigmas: json['use_karras_sigmas'] as String? ?? '',
      vae: json['vae'],
      loraStrength: json['lora_strength'] as String?,
      scheduler: json['scheduler'] as String? ?? '',
      webhook: json['webhook'] as String?,
      trackId: json['track_id'] as String?,
    );

Map<String, dynamic> _$Text2imgRequestToJson(Text2imgRequest instance) =>
    <String, dynamic>{
      'key': instance.key,
      'model_id': instance.modelId,
      'prompt': instance.prompt,
      'negative_prompt': instance.negativePrompt,
      'width': instance.width,
      'height': instance.height,
      'samples': instance.samples,
      'num_inference_steps': instance.numInferenceSteps,
      'safety_checker': instance.safetyChecker,
      'enhance_prompt': instance.enhancePrompt,
      'seed': instance.seed,
      'guidance_scale': instance.guidanceScale,
      'multi_lingual': instance.multiLingual,
      'panorama': instance.panorama,
      'self_attention': instance.selfAttention,
      'upscale': instance.upscale,
      'embeddings_model': instance.embeddingsModel,
      'lora_model': instance.loraModel,
      'tomesd': instance.tomesd,
      'clip_skip': instance.clipSkip,
      'use_karras_sigmas': instance.useKarrasSigmas,
      'vae': instance.vae,
      'lora_strength': instance.loraStrength,
      'scheduler': instance.scheduler,
      'webhook': instance.webhook,
      'track_id': instance.trackId,
    };
