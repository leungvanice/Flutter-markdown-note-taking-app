import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

final String tableNote = 'notes';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnDateTimeCreated = 'dateTimeCreated';
final String columnNoteDetail = 'noteDetail';

class Note {
  int id;
  String title;
  DateTime dateTimeCreated;
  String noteDetail;

  Note({this.id, this.title, this.dateTimeCreated, this.noteDetail});

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['_id'],
      title: map['title'],
      dateTimeCreated: DateTime.parse(map['dateTimeCreated']),
      noteDetail: map['noteDetail'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTimeCreated': dateTimeCreated.toString(),
      'noteDetail': noteDetail,
    };
  }
}

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

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
        $columnNoteDetail TEXT
      )
    ''');
  }

  Future<int> insert(Note note) async {
    Database db = await database;
    int id = await db.insert(tableNote, note.toMap());
    return id;
  }
}
