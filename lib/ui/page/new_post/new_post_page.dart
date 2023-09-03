import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<File> _images = [];
  final picker = ImagePicker();
  TextEditingController _textEditingController = TextEditingController();

  Future getImages() async {
    final pickedFiles = await picker.pickMultiImage(
        maxWidth: 1024, maxHeight: 1024, imageQuality: null);

    setState(() {
      if (pickedFiles.isNotEmpty) {
        _images =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      } else {
        print('No images selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发帖页面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: '请输入文字',
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: getImages,
                child: Text('选择图片'),
              ),
            ),
            SizedBox(height: 16.0),
            _images.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(children: [
                              Image.file(
                                _images[index],
                                height: 200,
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    }, icon: Icon(Icons.clear)),
                              )
                            ]),
                          ),
                        );
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Future.delayed(Duration(milliseconds: 2000));
          if (_textEditingController.text.isEmpty) {
            Get.snackbar("失败", '请输入文字');
            return;
          }
          if (_images.isEmpty) {
            Get.snackbar("失败", '请至少选择一张图片');
            return;
          }
          Get.snackbar("成功", '发布成功，请等待审核');
        },
        child: Icon(Icons.send),
      ),
    );
  }
}
