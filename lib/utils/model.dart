import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class Notes {
  int id;
  String Title;
  DateTime Date;
  String category;
  String status;
  int Reminder;
  String Description;

  Notes(this.Title, this.Date, this.category, this.status,
      this.Reminder, [this.Description]);
  Notes.withId(this.id,this.Title, this.Date, this.category, this.status,
      this.Reminder, [this.Description]);

  Map tomap() {
    Map<String, dynamic>map={'Title':this.Title,'Date':this.Date.toString(),'Category':this.category,'Status':this.status,'Reminder':this.Reminder,'Description':this.Description};
//    this.Title = map['Title'];
//    this.Date = map['Date'];
//    this.Time = map['Time'];
//    this.category = map['Category'];
//    this.status = map['Status'];
//    this.Reminder = map['Reminder'];
//    this.Description = map['Description'];
    return map;
  }
  Notes.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.Title = map['Title'];
    this.Date = DateTime.parse(map['Date']);
    this.category = map['Category'];
    this.status = map['Status'];
    this.Reminder = map['Reminder'];
    this.Description = map['Description'];
  }
}
class DatabaseHelper {

  static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
  static Database _database;                // Singleton Database

  String colId = "id";
  String table = "notes";
  String colTitle = "Title";
  String colDate = "Date";
  String colTime = "Time";
  String colCategory = 'Category';
  String colStatus = 'Status';
  String colReminder = 'Reminder';
  String colDescription = 'Description';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Open/create the database at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {

    await db.execute(
        'CREATE TABLE $table($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate Text, $colCategory TEXT, $colStatus TEXT, $colReminder INTEGER, $colDescription TEXT)');
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList(String sort) async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    if(sort=="Date A"){
      var result = await db.query(table,orderBy: '$colDate DESC',);
      return result;
    }else if(sort=="Date D"){
      var result = await db.query(table,orderBy: '$colDate ASC',);
      return result;
    }
    else if(sort=="Title A"){
      var result = await db.query(table,orderBy: '$colTitle ASC',);
      return result;
    }
    else if(sort=="Title D"){
      var result = await db.query(table,orderBy: '$colDate DESC',);
      return result;
    }
    else if(sort=="Latest"){
      var result = await db.query(table,orderBy: '$colId DESC',);
      return result;
    }
    else if(sort=="Oldest"){
      var result = await db.query(table,);
      return result;
    }

  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Notes note) async {
    Database db = await this.database;
    var result = await db.insert(table, note.tomap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Notes note) async {
    var db = await this.database;
    var result = await db.update(table, note.tomap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $table WHERE $colId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $table');
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Notes>> getNoteList(String sort) async {

    var noteMapList = await getNoteMapList(sort); // Get 'Map List' from database
    int count = noteMapList.length;         // Count the number of map entries in db table

    List<Notes> noteList = List<Notes>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Notes.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

}


/*class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  Database _database;
  String colId = "id";
  String table = "notes";
  String colTitle = "Title";
  String colDate = "Date";
  String colTime = "Time";
  String colCategory = 'Category';
  String colStatus = 'Status';
  String colReminder = 'Reminder';
  String colDescription = 'Description';


  DatabaseHelper._createInstance();

  factory DatabaseHelper(){
    if (_databaseHelper != null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }
  Future<Database> get database async{
    if(_database==null){
      _database=await initializeDatabse();
    }
    return _database;
  }
    Future initializeDatabse()async{
    Directory directory=await getApplicationDocumentsDirectory();
    String path=directory.path+"notes.db";
    var notesdb =await openDatabase(path,version: 1,onCreate: creatDb);
    return notesdb;



  }

  void creatDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $table($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDate DATE, $colTime TIME,$colCategory TEXT,$colStatus TEXT,$colReminder BOOL,$colDescription TEXT,)");
  }

 Future<List<Notes>> getnotes()async{
    List<Notes>data;
    Database db=await this.database;
    var result=await db.rawQuery("SELECT * FROM $table");
    for(int i=0;i<result.length;i++){
      data.add(Notes.fromMapObject(result[i]));
    }
    return data;


  }
  insertNotes(Map<String,dynamic>map)async{
    Database db=await database;
    var result =await db.rawQuery("INSERT INTO $table($colId,$colTitle,$colDate,$colTime,$colCategory,$colStatus,$colReminder,$colDescription)VALUES(${map['Title']},${map['Date']},${map['Time']},${map['Category']},${map['Status']},${map['Reminder']},${map['Description']},)");
    return result;

  }

}*/
/*bool value;
bool val(){
  if(widget.reminder==1){
    setState(() {
      value=true;
    });
  }
  else if(widget.reminder==0){
    setState(() {
      value=false;
    });
  }
}

onChanged(val) {
  setState(() {
    value = !value;
  });
  if (value) {
    setState(() {
      widget.reminder=1;
    });
  }else if(!value){
    setState(() {
      widget.reminder=0;
    });
  }

  print(widget.reminder);
}*/
