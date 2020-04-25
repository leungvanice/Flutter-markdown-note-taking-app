import './widgets/textEditor.dart';
import './widgets/preview.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MarkdownEditor(),
      theme: ThemeData(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          textTheme: TextTheme(
            title: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        tabBarTheme: TabBarTheme(
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.black),
          ),
          unselectedLabelColor: Colors.black,
          labelColor: Colors.black,
        ),
      ),
    );
  }
}

class MarkdownEditor extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("NOTE NAME"),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                child: Text("Edit"),
              ),
              Tab(
                child: Text("Preview"),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Container(
              child: TextEditor(textEditingController),
            ),
            Container(
              child: Preview(textEditingController),
            ),
          ],
        ),
      ),
    );
  }
}
