import 'package:intl/intl.dart';

import 'package:markdown_editor/database_helpers.dart';

import './noteDetail_page.dart';

import 'package:flutter/material.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.subject),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
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
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.description),
                title: Text('All Notes'),
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Trash'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.library_books),
                title: Text("FIrst Notebook"),
              ),
              SizedBox(
                height: 30,
              ),
              ListTile(
                trailing: FlatButton(
                  child: Text(
                    "+ Add Notebook",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
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
