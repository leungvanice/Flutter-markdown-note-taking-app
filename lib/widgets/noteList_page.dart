import 'package:intl/intl.dart';

import 'package:markdown_editor/database_helpers.dart';

import './createNotebook_page.dart';
import './noteDetail_page.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int i) {
    switch (i) {
      case 0:
        return AllNotesPage();
      case 1:
        return Container();
    }
  }

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
              Container(
                decoration: BoxDecoration(
                  color: 0 == _selectedDrawerIndex
                      ? Colors.grey[300]
                      : Colors.transparent,
                ),
                child: ListTile(
                  leading: Icon(Icons.description),
                  title: Text('All Notes'),
                  onTap: () => selectDrawerOption(0),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: 1 == _selectedDrawerIndex
                      ? Colors.grey[300]
                      : Colors.transparent,
                ),
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Trash'),
                  onTap: () => selectDrawerOption(1),
                ),
              ),
              Divider(),
              // display notebooks
              FutureBuilder(
                future: NotebookDatabaseHelper.instance.queryAllNotebooks(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Notebook>> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      height: snapshot.data.length * 50.0 + 10,
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: (snapshot.data[index].id + 2) ==
                                      _selectedDrawerIndex
                                  ? Colors.grey[300]
                                  : Colors.transparent,
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.library_books,
                                color: snapshot.data[index].color,
                              ),
                              title: Text(snapshot.data[index].title),
                              onTap: () => selectDrawerOption(snapshot.data[index].id + 2),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              // + Add Notebook btn
              ListTile(
                trailing: FlatButton(
                  child: Text(
                    "+ Add Notebook",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateNotebookPage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }

  selectDrawerOption(int i) {
    setState(() => _selectedDrawerIndex = i);
    Navigator.pop(context);
  }
}

class AllNotesPage extends StatefulWidget {
  @override
  _AllNotesPageState createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: NoteDatabaseHelper.instance.queryAllNotes(),
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
    );
  }
}

class NoteListPage extends StatefulWidget {
  final int drawerPosition;
  NoteListPage(this.drawerPosition);
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  // int noteId = widget.drawerPosition -2;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: NoteDatabaseHelper.instance
          .queryNoteByNotebook(widget.drawerPosition - 2),
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
    );
  }
}
