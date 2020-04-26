import './textEditor.dart';
import './preview.dart';

import '../database_helpers.dart';

import 'package:flutter/material.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;
  NoteDetailPage({this.note});
  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      setState(() {
        titleEditingController.text = widget.note.title;
        textEditingController.text = widget.note.noteDetail;
      });
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
    Note note = Note(
        title: titleEditingController.text,
        dateTimeCreated: DateTime.now(),
        noteDetail: textEditingController.text);
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.insert(note);
  }

  update() async {
    Note note = Note(
      id: widget.note.id,
      title: titleEditingController.text,
      dateTimeCreated: widget.note.dateTimeCreated,
      noteDetail: textEditingController.text,
    );
    int updatedId = await DatabaseHelper.instance.update(note);
    print(updatedId);
  }
}
