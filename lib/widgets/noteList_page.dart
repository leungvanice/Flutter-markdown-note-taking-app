import 'package:intl/intl.dart';

import 'package:markdown_editor/database_helpers.dart';

import './noteDetail_page.dart';

import 'package:flutter/material.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Markdown Editor"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NoteDetailPage()));
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: DatabaseHelper.instance.queryAllNotes(),
        builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailPage(
                          note: snapshot.data[index],
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(snapshot.data[index].title),
                    subtitle: Text(DateFormat('MMMM dd')
                        .add_jm()
                        .format(snapshot.data[index].dateTimeCreated)),
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
