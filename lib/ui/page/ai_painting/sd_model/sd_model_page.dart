import 'package:aimigo/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:aimigo/data/model/stablediffusion/sdcommunity/model_response/model_response.dart';
import 'package:aimigo/data/network.dart';
import 'package:aimigo/ui/route.dart';
import 'package:aimigo/ui/widget/markdown_block.dart';
import 'package:get/get.dart';

class SDModelPage extends StatefulWidget {
  SDModelPage({Key? key}) : super(key: key);

  @override
  State<SDModelPage> createState() => _SDModelPageState();
}

class _SDModelPageState extends State<SDModelPage>
    with AutomaticKeepAliveClientMixin {
  final selectedModel = Rx<SDModel?>(null);
  final modelList = <SDModel>[].obs;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text("模型")),
      body: RefreshIndicator(
        onRefresh: () async {
          getSDModel();
        },
        child: ScrollConfiguration(
          behavior: myScrollBehavior(context),
          child: MasonryGridView.count(
            padding: EdgeInsets.all(8),
            crossAxisCount: 2,
            // 每行显示的列数
            itemCount: modelList.length,
            itemBuilder: (BuildContext context, int index) {
              final item = modelList[index];
              return Container(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Get.toNamed(AppRoute.sdModelDetailPage, arguments: item);
                    // Get.toNamed(AppRoute.imageDetailsPage, arguments: item);
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: item.screenshots,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => SizedBox(
                              height: 200,
                              width: 200,
                              /* child:
                                    Center(child: CircularProgressIndicator())*/
                            ),
                            errorWidget: (context, url, error) => SizedBox(
                                height: 200,
                                width: 200,
                                child: Center(child: Icon(Icons.error))),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            // Text(item.suggestion, style:TextStyle(color: Colors.red)),
                            // Text(item.label, style:TextStyle(color: Colors.blue)),
                            Text(item.modelName),
                            // MyMarkdownBlock(data: item.description,builder: (widget)=>SelectionArea(child: widget),),
                            Text(
                              item.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            mainAxisSpacing: 8.0,
            // 主轴间距
            crossAxisSpacing: 8.0, // 横轴间距
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getSDModel();
  }

  getSDModel() async {
    try {
      final dio = await AppNetwork.getDio();
      final resp = await dio.post("/sdapi/v4/dreambooth/model_list");
      setState(() {
        modelList.value = sdModelListFormJson(resp.data);
      });
    } catch (e) {
      print(e);
      Get.snackbar("出错了", e.toString());
    }
  }

  @override
  bool get wantKeepAlive => true;
}
