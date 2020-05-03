import './edit.dart';
import './preview.dart';

import '../database_helpers.dart';

import 'package:flutter/material.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;
  final int belongedNotebookId;
  NoteDetailPage({this.note, this.belongedNotebookId});
  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage>
    with WidgetsBindingObserver {
  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.note != null) {
      setState(() {
        titleEditingController.text = widget.note.title;
        textEditingController.text = widget.note.noteDetail;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        widget.note == null ? save() : update();
        print("Detached");
        break;
      case AppLifecycleState.paused:
        widget.note == null ? save() : update();
        print("paused");

        break;
      case AppLifecycleState.inactive:
        widget.note == null ? save() : update();

        print("inactive");

        break;
      case AppLifecycleState.resumed:
        print("resumed");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: widget.note == null ? Text("Save") : Text("Done"),
                    onPressed: () async {
                      widget.note == null ? await save() : await update();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 65, right: 65),
                child: TextField(
                  controller: titleEditingController,
                  decoration: InputDecoration(border: InputBorder.none),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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

  save() async {
    String noteTitle;
    if (titleEditingController.text.isNotEmpty) {
      noteTitle = titleEditingController.text;
    } else {
      if (titleEditingController.text.isEmpty &&
          textEditingController.text.isNotEmpty) {
        noteTitle = textEditingController.text;
      } else {
        noteTitle = '(Blank note)';
      }
    }
    Note note = Note(
        title: noteTitle,
        dateTimeCreated: DateTime.now(),
        noteDetail: textEditingController.text);
    if (widget.belongedNotebookId != null) {
      note.belongedNotebookId = widget.belongedNotebookId;
    }

    print("Inserted notebook's id: ${note.belongedNotebookId}");
    NoteDatabaseHelper helper = NoteDatabaseHelper.instance;
    helper.insert(note);
  }

  update() async {
    String noteTitle;
    if (titleEditingController.text.isNotEmpty) {
      noteTitle = titleEditingController.text;
    } else {
      if (titleEditingController.text.isEmpty &&
          textEditingController.text.isNotEmpty) {
        noteTitle = textEditingController.text;
      } else {
        noteTitle = '(Blank note)';
      }
    }
    Note note = Note(
      id: widget.note.id,
      title: noteTitle,
      dateTimeCreated: widget.note.dateTimeCreated,
      noteDetail: textEditingController.text,
      belongedNotebookId: widget.note.belongedNotebookId,
    );
    int updatedId = await NoteDatabaseHelper.instance.update(note);
    print(updatedId);
  }
}
