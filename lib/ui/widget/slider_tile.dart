import 'package:flutter/material.dart';

class SliderTile extends StatelessWidget {
  final Widget title;
  final Slider slider;
  final Text? subtitle;

  const SliderTile({
    Key? key,
    required this.title,
    required this.slider,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(children: [
        Row(
          children: [
            title,
            if (subtitle != null) subtitle!,
          ],
        ),
        slider
      ]),
    );
  }
}