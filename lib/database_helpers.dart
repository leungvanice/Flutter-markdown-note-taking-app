import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

final String tableNote = 'notes';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnDateTimeCreated = 'dateTimeCreated';
final String columnNoteDetail = 'noteDetail';
final String columnBelongedNotebookId = 'belongedNotebookId';

final String tableNotebook = 'notebooks';
final String columnNotebookTitle = 'title';
final String columnNotebookDateCreated = 'dateCreated';
final String columnColorString = 'colorString';

final String tableTrash = 'trash';
final String columnDeletedDate = 'deletedDate';

class Note {
  int id;
  String title;
  DateTime dateTimeCreated;
  String noteDetail;
  int belongedNotebookId;

  Note(
      {this.id,
      this.title,
      this.dateTimeCreated,
      this.noteDetail,
      this.belongedNotebookId});

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['_id'],
      title: map['title'],
      dateTimeCreated: DateTime.parse(map['dateTimeCreated']),
      noteDetail: map['noteDetail'],
      belongedNotebookId: map['belongedNotebookId'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTimeCreated': dateTimeCreated.toString(),
      'noteDetail': noteDetail,
      'belongedNotebookId': belongedNotebookId,
    };
  }
}

class Notebook {
  int id;
  String title;
  DateTime dateCreated;
  Color color;
  Notebook({this.id, this.title, this.dateCreated, this.color});

  static Color colorFromString(String colorString) {
    String valueString = colorString.split('(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);
    Color color = Color(value);
    return color;
  }

  factory Notebook.fromMap(Map<String, dynamic> map) {
    return Notebook(
      id: map['_id'],
      title: map['title'],
      dateCreated: DateTime.parse(map['dateCreated']),
      color: colorFromString(map['colorString']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateCreated': dateCreated.toString(),
      'colorString': color.toString(),
    };
  }
}

class TrashNote {
  int id;
  DateTime deletedDate;
  Note note;
  TrashNote({this.id, this.deletedDate, this.note});

  factory TrashNote.fromMap(Map<String, dynamic> map) {
    Note note = Note(
      title: map['title'],
      dateTimeCreated: DateTime.parse(map['dateTimeCreated']),
      noteDetail: map['noteDetail'],
      belongedNotebookId: map['belongedNotebookId'],
    );
    return TrashNote(
      id: map['_id'],
      deletedDate: DateTime.parse(map['deletedDate']),
      note: note,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'deletedDate': deletedDate.toString(),
      'title': note.title,
      'dateTimeCreated': note.dateTimeCreated.toString(),
      'noteDetail': note.noteDetail,
      'belongedNotebookId': note.belongedNotebookId,
    };
  }
}

class NoteDatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  NoteDatabaseHelper._privateConstructor();
  static final NoteDatabaseHelper instance =
      NoteDatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNote (
        $columnId INTEGER PRIMARY KEY, 
        $columnTitle TEXT NOT NULL, 
        $columnDateTimeCreated TEXT NOT NULL, 
        $columnNoteDetail TEXT, 
        $columnBelongedNotebookId INTEGER
      )
    ''');
  }

  Future<int> insert(Note note) async {
    Database db = await database;
    int id = await db.insert(tableNote, note.toMap());
    return id;
  }

  Future<List<Note>> queryAllNotes() async {
    final db = await database;
    var res = await db.query(tableNote);
    List<Note> list =
        res.isNotEmpty ? res.map((note) => Note.fromMap(note)).toList() : [];
    return list;
  }

  Future<List<Note>> queryNoteByNotebook(int belongedNotebookId) async {
    final db = await database;
    var res = await db.query(tableNote,
        where: "belongedNotebookId = ?", whereArgs: [belongedNotebookId]);
    List<Note> list =
        res.isNotEmpty ? res.map((note) => Note.fromMap(note)).toList() : [];
    return list;
  }

  Future<int> update(Note note) async {
    final db = await database;
    int id = await db.update(tableNote, note.toMap(),
        where: '_id = ?', whereArgs: [note.id]);
    return id;
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    int deletedId =
        await db.delete(tableNote, where: "_id = ?", whereArgs: [id]);
    return deletedId;
  }
}

class NotebookDatabaseHelper {
  static final _databaseName = 'NotebookDB.db';
  static final _databaseVersion = 1;

  NotebookDatabaseHelper._();
  static final NotebookDatabaseHelper instance = NotebookDatabaseHelper._();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNotebook ( 
        $columnId INTEGER PRIMARY KEY, 
        $columnNotebookTitle TEXT NOT NULL, 
        $columnNotebookDateCreated TEXT NOT NULL, 
        $columnColorString TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Notebook notebook) async {
    Database db = await database;
    int id = await db.insert(tableNotebook, notebook.toMap());
    return id;
  }

  Future<Notebook> queryNotebook(int id) async {
    final db = await database;
    var res = await db.query(tableNotebook, where: '_id = ?', whereArgs: [id]);
    return res.isNotEmpty ? Notebook.fromMap(res.first) : Null;
  }

  Future<List<Notebook>> queryAllNotebooks() async {
    Database db = await database;
    var res = await db.query(tableNotebook);
    List<Notebook> list = res.isNotEmpty
        ? res.map((notebook) => Notebook.fromMap(notebook)).toList()
        : [];
    return list;
  }

  Future<int> updateNotebookTitle(int id, String newTitle) async {
    final db = await database;
    Notebook notebook = await queryNotebook(id);
    notebook.title = newTitle;
    var res = await db.update(tableNotebook, notebook.toMap(),
        where: "_id = ?", whereArgs: [id]);
    return res;
  }
}

class TrashDatabaseHelper {
  static final _databaseName = "TrashDatabase.db";
  static final _databaseVersion = 1;

  TrashDatabaseHelper._privateConstructor();
  static final TrashDatabaseHelper instance =
      TrashDatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTrash (
        $columnId INTEGER PRIMARY KEY, 
        $columnDeletedDate TEXT NOT NULL,
        $columnTitle TEXT NOT NULL, 
        $columnDateTimeCreated TEXT NOT NULL, 
        $columnNoteDetail TEXT, 
        $columnBelongedNotebookId INTEGER
      )
    ''');
  }

  Future<int> insert(TrashNote trashNote) async {
    final db = await database;
    int id = await db.insert(tableTrash, trashNote.toMap());
    return id;
  }

  Future<List<TrashNote>> queryAllTrashNote() async {
    final db = await database;
    var res = await db.query(tableTrash);
    await deleteNoteOver30DaysInTrash();

    List<TrashNote> list = res.isNotEmpty
        ? res.map((note) => TrashNote.fromMap(note)).toList()
        : [];
    return list;
  }

  deleteNoteOver30DaysInTrash() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    final db = await database;
    var res = await db.query(tableTrash);
    print(today.subtract(Duration(days: 30)));
    List<TrashNote> list = res.isNotEmpty
        ? res.map((note) => TrashNote.fromMap(note)).toList()
        : [];

    list.forEach((note) {
      DateTime deletedDate = DateTime(
          note.deletedDate.year, note.deletedDate.month, note.deletedDate.day);
      int elapsedDays = (today.difference(deletedDate).inDays);
      int remainedDays = 30 - elapsedDays - 1;

      if (remainedDays <= 1) {
        delete(note.id);
      }
    });
  }

  Future<int> delete(int id) async {
    final db = await database;
    int deletedId =
        await db.delete(tableTrash, where: "_id = ?", whereArgs: [id]);
    return deletedId;
  }

  deleteAll() async {
    final db = await database;
    await db.execute("DELETE FROM $tableTrash");
  }
}
