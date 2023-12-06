import 'package:flutter/material.dart';
import 'package:markdown_widget/config/all.dart';

typedef MarkdownBlockBuilder = Widget Function(Widget child);

///use [MyMarkdownBlock] to build markdown by [Column]
///it does not support scrolling by default, but it will adapt to the width automatically.
class MyMarkdownBlock extends StatelessWidget {
  ///the markdown data
  final String data;

  ///make text selectable
  final MarkdownBlockBuilder? builder;

  ///the configs of markdown
  final MarkdownConfig? config;

  ///config for [MarkdownGenerator]
  final MarkdownGenerator? generator;

  final bool isSourceMode;

  const MyMarkdownBlock({
    Key? key,
    required this.data,
    this.builder,
    this.isSourceMode = false,
    this.config,
    this.generator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final markdownGenerator = generator ?? MarkdownGenerator();
    final widgets = markdownGenerator.buildWidgets(data, config: config);

    final child = isSourceMode
        ? Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(data, style: TextStyle(fontSize: 16)),
        )
        : Column(
            children: widgets,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          );
    return builder != null ? builder!.call(child) : child;
  }
}
