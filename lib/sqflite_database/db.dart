
/*******************************DATABASE Connection***********************************/

import 'package:notely/model/note_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotesDatabase {
  NotesDatabase._init(); // private constructor
  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database;

  // Open Database
  Future<Database> get dataBase async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDB('notes.db'); /// creating a notes table in NotesDatabase
      return _database!;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //Create Table
  Future _createDB(Database db, int version) async {
    var idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    var textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE $tableNotes ( 
  ${NoteFields.id} $idType,                             // Note Id
  ${NoteFields.title} $textType,                        // Note Title
  ${NoteFields.description} $textType,                  // Note Description
  ${NoteFields.time} $textType                          // Note Time
  )
''');
  }

  // CRUD Operations

  Future<Note> create(Note note) async {    /// Creating a note
    final db = await instance.dataBase;

    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }


  Future<Note> readNote(int id) async {        /// Reading a particular note
    final db = await instance.dataBase;

    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Note>> readAllNotes() async {     /// reading all the notes in decreasing order of time
    final db = await instance.dataBase;

    final orderBy = '${NoteFields.time} DESC';
    final result =
        await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<List<Note>> readAllNotes_InAscendingOrder() async {     /// reading all the notes in ascending order of time
    final db = await instance.dataBase;

    final orderBy = '${NoteFields.time} ASC';
    final result =
    await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    return result.map((json) => Note.fromJson(json)).toList();
  }


  Future<int> update(Note note) async {      /// Updating a particular Note
    final db = await instance.dataBase;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }


  Future<int> delete(int id) async {  /// deleting a particular Note
    final db = await instance.dataBase;
    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }


  Future close() async {          /// Close the Database
    final db = await instance.dataBase;
    db.close();
  }
}
