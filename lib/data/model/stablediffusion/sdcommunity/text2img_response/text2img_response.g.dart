// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text2img_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Text2imgResponse _$Text2imgResponseFromJson(Map<String, dynamic> json) =>
    Text2imgResponse(
      status: json['status'] as String? ?? '',
      generationTime: (json['generationTime'] as num?)?.toDouble() ?? 0.0,
      id: json['id'] as int? ?? 0,
      output: (json['output'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$Text2imgResponseToJson(Text2imgResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'generationTime': instance.generationTime,
      'id': instance.id,
      'output': instance.output,
      'meta': instance.meta.toJson(),
    };

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
      prompt: json['prompt'] as String? ?? '',
      modelId: json['model_id'] as String? ?? '',
      negativePrompt: json['negative_prompt'] as String? ?? '',
      scheduler: json['scheduler'] as String? ?? '',
      safetychecker: json['safetychecker'] as String? ?? '',
      w: json['W'] as int? ?? 0,
      h: json['H'] as int? ?? 0,
      guidanceScale: (json['guidance_scale'] as num?)?.toDouble() ?? 0.0,
      seed: json['seed'] as int? ?? 0,
      steps: json['steps'] as int? ?? 0,
      nSamples: json['n_samples'] as int? ?? 0,
      fullUrl: json['full_url'] as String? ?? '',
      upscale: json['upscale'] as String? ?? '',
      multiLingual: json['multi_lingual'] as String? ?? '',
      panorama: json['panorama'] as String? ?? '',
      selfAttention: json['self_attention'] as String? ?? '',
      embeddings: json['embeddings'],
      lora: json['lora'],
      outdir: json['outdir'] as String? ?? '',
      filePrefix: json['file_prefix'] as String? ?? '',
    );

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
      'prompt': instance.prompt,
      'model_id': instance.modelId,
      'negative_prompt': instance.negativePrompt,
      'scheduler': instance.scheduler,
      'safetychecker': instance.safetychecker,
      'W': instance.w,
      'H': instance.h,
      'guidance_scale': instance.guidanceScale,
      'seed': instance.seed,
      'steps': instance.steps,
      'n_samples': instance.nSamples,
      'full_url': instance.fullUrl,
      'upscale': instance.upscale,
      'multi_lingual': instance.multiLingual,
      'panorama': instance.panorama,
      'self_attention': instance.selfAttention,
      'embeddings': instance.embeddings,
      'lora': instance.lora,
      'outdir': instance.outdir,
      'file_prefix': instance.filePrefix,
    };
