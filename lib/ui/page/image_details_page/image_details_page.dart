import 'package:flutter/material.dart';

class ImageDetailsPage extends StatefulWidget {
  final Map data;

  const ImageDetailsPage({Key? key, required this.data}) : super(key: key);

  @override
  State<ImageDetailsPage> createState() => _ImageDetailsPageState();
}

class _ImageDetailsPageState extends State<ImageDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("详情"),
        ),
        body: Column(
          children: [
            Image.asset(widget.data['image']),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.data['title']),
            ),
          ],
        ));
  }
}
