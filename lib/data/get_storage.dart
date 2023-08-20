import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

late GetStorage getStorage;

Future<void> initGetStorage() async {
  if (!GetPlatform.isWeb) {
    final path = await getApplicationSupportDirectory();
    getStorage = GetStorage('GetStorage', path.path);
  }else {
    getStorage = GetStorage('GetStorage');
  }
  await getStorage.initStorage;
}
