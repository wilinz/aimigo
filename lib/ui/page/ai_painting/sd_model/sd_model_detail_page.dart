import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:aimigo/data/model/stablediffusion/sdcommunity/model_response/model_response.dart';
import 'package:aimigo/ui/route.dart';
import 'package:aimigo/ui/widget/markdown_block.dart';
import 'package:aimigo/ui/widget/selection_transformer.dart';
import 'package:get/get.dart';

class SDModelDetailPage extends StatefulWidget {
  const SDModelDetailPage({Key? key, required this.model}) : super(key: key);

  final SDModel model;

  @override
  State<SDModelDetailPage> createState() => _SDModelDetailPageState();
}

class _SDModelDetailPageState extends State<SDModelDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("详情"),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_outline),
            onPressed: () async {
              Future.delayed(Duration(milliseconds: 500));
              Get.snackbar('成功', "收藏成功");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: widget.model.screenshots,
              placeholder: (context, url) => SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(child: Icon(Icons.error))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(widget.model.modelName, style: TextStyle(fontSize: 18)),
                  MyMarkdownBlock(
                    data: widget.model.description,
                    builder: (widget) => SelectionTransformer.separated(
                        child: SelectionArea(child: widget)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoute.text2ImgPage, arguments: widget.model);
        },
        child: Icon(Icons.brush), // FAB上的图标
      ),
    );
  }
}
