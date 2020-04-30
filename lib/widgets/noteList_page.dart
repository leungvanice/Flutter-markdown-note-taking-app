import 'package:intl/intl.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
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

  TextEditingController notebookTitleController = TextEditingController();
  String _selectedNotebookName;
  int _selectedNotebookId;
  appBarTitle(int i) {
    switch (i) {
      case 0:
        return Text("Markdown Editor");
      case 1:
        return Text("Trash");
      default:
        notebookTitleController.text = _selectedNotebookName;
        return TextField(
          controller: notebookTitleController,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
          onSubmitted: (txt) async {
            int updatedId = await NotebookDatabaseHelper.instance
                .updateNotebookTitle(_selectedNotebookId, txt);
            print("Updated $updatedId");
            setState(() {});
          },
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        );
    }
  }

  _getDrawerItemWidget(int i) {
    switch (i) {
      case 0:
        return AllNotesPage();
      case 1:
        return TrashListPage();
      default:
        return NoteListPage(i - 2);
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
        title: appBarTitle(_selectedDrawerIndex),
        actions: <Widget>[
          _selectedDrawerIndex == 1
              ? FlatButton(
                  child: Text("Clear All"),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text("Delete All?"),
                        content: Text("You can't recover them again."),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text("Yes"),
                            onPressed: () async {
                              await TrashDatabaseHelper.instance.deleteAll();
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                )
              : IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_selectedDrawerIndex == 0 ||
                        _selectedDrawerIndex == 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NoteDetailPage()));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NoteDetailPage(
                                    belongedNotebookId:
                                        _selectedDrawerIndex - 2,
                                  )));
                    }
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
                  onTap: () => selectDrawerOption(0, '', 0),
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
                  onTap: () => selectDrawerOption(1, '', 0),
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
                              onLongPress: () async {
                                await showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    title: Text("Delete notebook?"),
                                    content: Text(
                                        "The notes belonged to this notebook will also be deleted and you can't recover them. "),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("No"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text("Yes"),
                                        onPressed: () async {
                                          int id = await NotebookDatabaseHelper
                                              .instance
                                              .delete(snapshot.data[index].id);

                                          List<Note> list =
                                              await NoteDatabaseHelper
                                                  .instance
                                                  .queryNoteByNotebook(
                                                      snapshot.data[index].id);
                                          list.forEach((note) async {
                                            await NoteDatabaseHelper.instance
                                                .deleteNote(note.id);
                                          });
                                          print("$id deleted");

                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              leading: Icon(
                                Icons.library_books,
                                color: snapshot.data[index].color,
                              ),
                              title: Text(snapshot.data[index].title),
                              onTap: () => selectDrawerOption(
                                snapshot.data[index].id + 2,
                                snapshot.data[index].title,
                                snapshot.data[index].id,
                              ),
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

  selectDrawerOption(int i, String notebookTitle, int notebookId) {
    setState(() {
      _selectedNotebookName = notebookTitle;
      _selectedNotebookId = notebookId;
      _selectedDrawerIndex = i;
    });
    print("Selected drawer: $_selectedDrawerIndex");
    Navigator.pop(context);
  }
}

class AllNotesPage extends StatefulWidget {
  @override
  _AllNotesPageState createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> {
  final SlidableController slidableController = SlidableController();
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
                child: Slidable(
                  key: Key(index.toString()),
                  controller: slidableController,
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.2,
                  child: ListTile(
                    title: Text(snapshot.data[index].title),
                    subtitle: Text(DateFormat('MMMM dd yyyy')
                        .format(snapshot.data[index].dateTimeCreated)),
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async {
                        TrashNote trashNote = TrashNote(
                            deletedDate: DateTime.now(),
                            note: snapshot.data[index]);
                        int insertedId = await TrashDatabaseHelper.instance
                            .insert(trashNote);
                        print(insertedId);
                        await NoteDatabaseHelper.instance
                            .deleteNote(snapshot.data[index].id);

                        setState(() {});
                      },
                    ),
                  ],
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

  Widget getNotebookTitle(int id) {
    return FutureBuilder(
      future: NotebookDatabaseHelper.instance.queryNotebook(id),
      builder: (BuildContext context, AsyncSnapshot<Notebook> snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data.title);
        } else {
          return Text("No data");
        }
      },
    );
  }
}

class NoteListPage extends StatefulWidget {
  final int notebookId;
  NoteListPage(this.notebookId);
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final SlidableController slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          NoteDatabaseHelper.instance.queryNoteByNotebook(widget.notebookId),
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
                child: Slidable(
                  key: Key(index.toString()),
                  controller: slidableController,
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.2,
                  child: ListTile(
                    title: Text(snapshot.data[index].title),
                    subtitle: Text(DateFormat('MMMM dd yyyy')
                        .format(snapshot.data[index].dateTimeCreated)),
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async {
                        TrashNote trashNote = TrashNote(
                            deletedDate: DateTime.now(),
                            note: snapshot.data[index]);
                        int insertedId = await TrashDatabaseHelper.instance
                            .insert(trashNote);
                        print(insertedId);
                        await NoteDatabaseHelper.instance
                            .deleteNote(snapshot.data[index].id);
                        setState(() {});
                      },
                    ),
                  ],
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

class TrashListPage extends StatefulWidget {
  @override
  _TrashListPageState createState() => _TrashListPageState();
}

class _TrashListPageState extends State<TrashListPage> {
  final SlidableController slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: TrashDatabaseHelper.instance.queryAllTrashNote(),
      builder: (BuildContext context, AsyncSnapshot<List<TrashNote>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              DateTime now = DateTime.now();
              DateTime today = DateTime(now.year, now.month, now.day);
              DateTime deletedDate = DateTime(
                  snapshot.data[index].deletedDate.year,
                  snapshot.data[index].deletedDate.month,
                  snapshot.data[index].deletedDate.day);
              int elapsedDays = (today.difference(deletedDate).inDays);
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailPage(
                        note: snapshot.data[index].note,
                      ),
                    ),
                  );
                },
                child: Slidable(
                  key: Key(index.toString()),
                  controller: slidableController,
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.2,
                  child: ListTile(
                    title: Text(snapshot.data[index].note.title),
                    subtitle: Text("${(30 - elapsedDays - 1).toString()} Days"),
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Recover',
                      color: Colors.grey,
                      icon: Icons.history,
                      onTap: () async {
                        Note note = snapshot.data[index].note;
                        await NoteDatabaseHelper.instance.insert(note);
                        await TrashDatabaseHelper.instance
                            .delete(snapshot.data[index].id);
                        setState(() {});
                      },
                    ),
                  ],
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
