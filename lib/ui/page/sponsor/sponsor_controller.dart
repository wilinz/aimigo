
import 'package:aimigo/data/network.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SponsorController extends GetxController{

  final qrCodeText = "".obs;

  void pay() {
    launchUrlString(qrCodeText.value,mode: LaunchMode.externalNonBrowserApplication);
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    final data = {
      "total_amount":"1",
      "subject":"给开发者点赞"
    };
    // {"code":"10000","msg":"Success","sub_code":"","sub_msg":"","out_trade_no":"1742259131210797056","qr_code":"https://qr.alipay.com/xxx"}
    final resp = await AppNetwork.get().dio.post("/pay/precreate",data: data);
    qrCodeText.value = resp.data["qr_code"];

  }

}