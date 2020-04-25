import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

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
        onTapLink: (url) {
          canLaunch(url).then(
            (canLaunchURL) {
              if (canLaunchURL) {
                launch(url);
              }
            },
          );
        });
  }
}
