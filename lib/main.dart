import './widgets/noteList_page.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NoteListPage(),
      theme: ThemeData(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
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
      routes: {
        '/note-list': (context) => NoteListPage(),
      },
    );
  }
}
