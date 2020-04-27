import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../database_helpers.dart';

import 'package:flutter/material.dart';

class CreateNotebookPage extends StatefulWidget {
  @override
  _CreateNotebookPageState createState() => _CreateNotebookPageState();
}

class _CreateNotebookPageState extends State<CreateNotebookPage> {
  TextEditingController titleController = TextEditingController();
  ValueNotifier titleValue = ValueNotifier('');
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Notebook"),
        actions: <Widget>[
          ValueListenableBuilder(
            valueListenable: titleValue,
            builder: (context, value, child) {
              return FlatButton(
                child: Text("Done"),
                onPressed: titleValue.value == '' ? null : save,
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 30,
                  margin: EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: Icon(Icons.library_books),
                    color: currentColor,
                    onPressed: () {
                      showDialog(
                        context: context,
                        child: AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: currentColor,
                              onColorChanged: changeColor,
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text('Got it'),
                              onPressed: () {
                                setState(() => currentColor = pickerColor);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: titleController,
                    onChanged: (val) {
                      titleValue.value = val;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter notebook title",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ), 
      ),
    );
  }

  save() async {
    Notebook notebook = Notebook(
      title: titleController.text,
      color: currentColor,
      dateCreated: DateTime.now(),
    );
    NotebookDatabaseHelper helper = NotebookDatabaseHelper.instance;
    int insertedId = await helper.insert(notebook);
    print('Inserted: $insertedId');

    Navigator.pop(context);
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
}
