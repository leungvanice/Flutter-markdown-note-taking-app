import 'package:flutter/material.dart';

class CreateNotebookPage extends StatefulWidget {
  @override
  _CreateNotebookPageState createState() => _CreateNotebookPageState();
}

class _CreateNotebookPageState extends State<CreateNotebookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Notebook"),
      ),
    );
  }
}
