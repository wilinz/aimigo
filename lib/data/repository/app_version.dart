import 'package:aimigo/data/model/app/app_version/app_version.dart';
import 'package:aimigo/data/network.dart';
import 'package:aimigo/package_info.dart';

class AppRepository {
  Future<AppVersionResponse> getAppVersion() async {
    final response = await AppNetwork.get().dio.get("/app/app_version",
        queryParameters: {"appid": "com.wilinz.aimigo"});
    return AppVersionResponse.fromJson(response.data);
  }

  AppRepository._create();

  static AppRepository? _instance;

  factory AppRepository.get() => _instance ??= AppRepository._create();
}
