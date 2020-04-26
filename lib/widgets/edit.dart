import 'package:flutter/material.dart';

class TextEditor extends StatefulWidget {
  final TextEditingController textEditingController;
  TextEditor(this.textEditingController);
  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: widget.textEditingController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        autocorrect: false,
      ),
    );
  }
}
