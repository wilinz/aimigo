import 'dart:io';
import 'dart:typed_data';

import 'package:dart_extensions/dart_extensions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:flutter/widgets.dart';
import 'package:aimigo/data/model/stablediffusion/sdcommunity/model_response/model_response.dart';
import 'package:aimigo/data/model/stablediffusion/sdcommunity/text2img_request/text2img_request.dart';
import 'package:aimigo/data/model/stablediffusion/sdcommunity/text2img_response/text2img_response.dart';
import 'package:aimigo/data/network.dart';
import 'package:aimigo/util/bool.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

/// | Parameter               | Description                                                  |
/// | ----------------------- | ------------------------------------------------------------ |
/// | **key**                 | Your API Key used for request authorization                  |
/// | **model_id**            | The id of the model. **[get model_id from here](https://stablediffusionapi.com/models)**. |
/// | **prompt**              | Text prompt with description of the things you want in the image to be generated |
/// | **negative_prompt**     | Items you don't want in the image                            |
/// | **width**               | Max Height: Width: 1024x1024                                 |
/// | **height**              | Max Height: Width: 1024x1024                                 |
/// | **samples**             | Number of images to be returned in response. The maximum value is 4. |
/// | **num_inference_steps** | Number of denoising steps (minimum: 1; maximum: 50)          |
/// | **safety_checker**      | A checker for NSFW images. If such an image is detected, it will be replaced by a blank image. |
/// | **safety_checker_type** | Modify image if NSFW images are found; **default**: sensitive_content_text, **options**: blur/sensitive_content_text/pixelate/black |
/// | **enhance_prompt**      | Enhance prompts for better results; **default**: yes, **options**: yes/no |
/// | **seed**                | Seed is used to reproduce results, same seed will give you same image in return again. Pass *null* for a random number. |
/// | **guidance_scale**      | Scale for classifier-free guidance (minimum: 1; maximum: 20) |
/// | **tomesd**              | Enable tomesd to generate images: gives really fast results, **default**: yes, **options**: yes/no |
/// | **use_karras_sigmas**   | Use keras sigmas to generate images. gives nice results, **default**: yes, **options**: yes/no |
/// | **algorithm_type**      | Used in DPMSolverMultistepScheduler scheduler, **default**: none, **options**: sde-dpmsolver++ |
/// | **vae**                 | use custom vae in generating images **default**: null        |
/// | **lora_strength**       | Strength of lora model you are using. If using multi lora, pass each values as comma saparated |
/// | **lora_model**          | pass Lora model id, multi lora is supported, pass comma saparated values. Example contrast-fix,yae-miko-genshin |
/// | **multi_lingual**       | Allow multi lingual prompt to generate images. Set this to "yes" if you use a [language](https://stablediffusionapi.com/docs/community-models-api-v4/dreamboothtext2img#multi_lingual-supported-languages) different from English in your text prompts. |
/// | **panorama**            | Set this parameter to "yes" to generate a panorama image.    |
/// | **self_attention**      | If you want a high quality image, set this parameter to "yes". In this case the image generation will take more time. |
/// | **upscale**             | Set this parameter to "2" if you want to upscale the given image resolution two times (2x), **options**:: 1, 2, 3 |
/// | **clip_skip**           | Clip Skip (minimum: 1; maximum: 8)                           |
/// | **base64**              | Get response as base64 string, **default**: "no", **options**: yes/no |
/// | **embeddings_model**    | Use it to pass an embeddings model.                          |
/// | **scheduler**           | Use it to set a [scheduler](https://stablediffusionapi.com/docs/community-models-api-v4/dreamboothtext2img#schedulers). |
/// | **webhook**             | Set an URL to get a POST API call once the image generation is complete. |
/// | **track_id**            | This ID is returned in the response to the webhook API call. This will be used to identify the webhook request. |
/// | **temp**                | Create temp image link. This link is valid for 24 hours. **temp**: yes, **options**: yes/no |
class Text2ImgPageController extends GetxController {
  final promptController = TextEditingController();
  final negativePromptController = TextEditingController();

  final seedController = TextEditingController();
  final loraModel = TextEditingController();
  final loraStrength = TextEditingController();
  final embeddingsModel = TextEditingController();

  final isPromptNotBlank = false.obs;
  final width = 512.obs;
  final height = 768.obs;
  final number = 1.obs;
  final steps = 30.obs;
  final isEnhancePrompt = true.obs;
  final guidanceScale = 7.5.obs;
  final panorama = false.obs;
  final selfAttention = true.obs;
  final upscale = 0.obs;
  final clipSkip = 2.obs;
  final tomesd = true.obs;
  final useKarrasSigmas = true.obs;
  final scheduler = "".obs;
  final multiLingual = true.obs;

  final isShowAdvancedOptions = false.obs;
  final outputImages = <String>[].obs;

  final SDModel model;

  final List<String> availableSchedulers = [
    'DDPMScheduler',
    'DDIMScheduler',
    'PNDMScheduler',
    'LMSDiscreteScheduler',
    'EulerDiscreteScheduler',
    'EulerAncestralDiscreteScheduler',
    'DPMSolverMultistepScheduler',
    'HeunDiscreteScheduler',
    'KDPM2DiscreteScheduler',
    'DPMSolverSinglestepScheduler',
    'KDPM2AncestralDiscreteScheduler',
    'UniPCMultistepScheduler',
    'DDIMInverseScheduler',
    'DEISMultistepScheduler',
    'IPNDMScheduler',
    'KarrasVeScheduler',
    'ScoreSdeVeScheduler',
  ];

  Text2ImgPageController({required this.model});

  @override
  void onInit() {
    super.onInit();
    scheduler.value = availableSchedulers.first;
    promptController.addListener(() {
      isPromptNotBlank.value = promptController.text.isNotBlank;
    });
  }

  generate(CancelToken cancelToken) async {
    final text2imgRequest = Text2imgRequest(
      key: "",
      modelId: model.modelId,
      prompt: promptController.text,
      negativePrompt: negativePromptController.text,
      width: width.string,
      height: height.string,
      samples: number.string,
      numInferenceSteps: steps.string,
      safetyChecker: "",
      enhancePrompt: isEnhancePrompt.toYesOrNo(),
      guidanceScale: guidanceScale.toStringAsFixed(2).toDoubleOrNull()!,
      multiLingual: multiLingual.toYesOrNo(),
      panorama: panorama.toYesOrNo(),
      selfAttention: selfAttention.toYesOrNo(),
      upscale: getUpscale(upscale.value),
      tomesd: tomesd.toYesOrNo(),
      clipSkip: clipSkip.string,
      useKarrasSigmas: useKarrasSigmas.toYesOrNo(),
      scheduler: scheduler.string,
      seed: seedController.text.toIntOrNull(),
      embeddingsModel: embeddingsModel.text,
      loraModel: loraModel.text,
      vae: null,
      loraStrength: loraStrength.text,
    );

    final dio = await AppNetwork.getDio();
    final resp = await dio.post("/sdapi/v4/dreambooth",
        data: text2imgRequest.toJson(), cancelToken: cancelToken);
    final result = Text2imgResponse.fromJson(resp.data);
    if (result.status != "success") throw Exception("生成失败，请检查参数");
    outputImages.value = result.output;
  }

  String getUpscale(int upscale) {
    if (upscale < 1) return "no";
    return upscale.toString();
  }

  saveNetworkImage(String url) async {
    // Used libs follows:
    //   device_info_plus: ^10.1.0
    //   saver_gallery: ^3.0.5
    if (GetPlatform.isDesktop) {
      Get.snackbar("失败", "暂不支持非移动端");
      return;
    }
    bool isGranted;
    if (Platform.isAndroid) {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      isGranted = await (sdkInt > 33 ? Permission.photos : Permission.storage)
          .request()
          .isGranted;
    } else {
      isGranted = await Permission.photosAddOnly.request().isGranted;
    }

    if (isGranted) {
      String picturesPath =
          DateTime.timestamp().millisecondsSinceEpoch.toString() + ".jpg";
      debugPrint(picturesPath);
      var response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      final result = await SaverGallery.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        fileName: picturesPath,
        androidRelativePath: "Pictures/Aimigo",
        skipIfExists: false,
      );
      debugPrint(result.toString());
      Get.snackbar("成功", "保存成功");
    } else {
      Get.snackbar("失败", "请允许权限");
    }
  }
}
