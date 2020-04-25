import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Preview extends StatelessWidget {
  final TextEditingController textEditingController;
  Preview(this.textEditingController);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: markdownPreview(textEditingController.text, context),
    );
  }

  Widget markdownPreview(String text, context) {
    FocusScope.of(context).requestFocus(FocusNode());
    return Markdown(
      data: text,
    );
  }
}
