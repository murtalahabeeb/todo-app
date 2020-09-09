import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/list.dart';
import 'package:todo_app/utils/model.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share/share.dart';

class Notepage extends StatefulWidget {
  @override
  _NotepageState createState() => _NotepageState();
}

class _NotepageState extends State<Notepage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Notes> NoteList;
  bool done = false;
  String query = "";
  String sort = "Latest";


  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Notes>> noteListFuture = databaseHelper.getNoteList(sort);
      noteListFuture.then((noteList) {
        setState(() {
          this.NoteList = noteList;
        });
      });
    });
  }

  Widget show(scaler) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    List<Notes> sugest = NoteList.where((notes) {

      return (notes.Title.contains(query) || notes.Description.contains(query));
    }).toList();
    return  Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 15.0),
      child: GridView.builder(
        //reverse: true,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          primary: false,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: (itemWidth / itemHeight)),
          itemCount: sugest.length,
          itemBuilder: (context, index) {
            return Container(
              clipBehavior: Clip.antiAlias,
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.15,
                closeOnScroll: false,




                direction: Axis.vertical,
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            databaseHelper.deleteNote(
                                sugest[index].id);
                            updateListView();
                          },
                          child: Icon(Icons.delete,color: Colors.white,)),
                      GestureDetector(
                          onTap: () {
                            final RenderBox box = context.findRenderObject();
                            Share.share("${sugest[index].Title} on ${sugest[index].Date} by ${DateFormat.jm(sugest[index].Date) }\n ${sugest[index].Description}",
                                subject: "Todo Task",
                                sharePositionOrigin:
                                box.localToGlobal(Offset.zero) &
                                box.size);
                          },
                          child: Icon(Icons.share,color: Colors.white,)),
                    ],
                  ),
                ],
                key: Key(sugest[index].id.toString()),
                child: Notelist(
                    sugest[index].id,
                    sugest[index].Title,
                    sugest[index].Date,
                    sugest[index].category,
                    sugest[index].Reminder,
                    sugest[index].status,
                    sugest[index].Description),
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()
      ..init(context);
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;


    if (NoteList == null) {
      NoteList = List<Notes>();
      // updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Timed",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.blueGrey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: () async {

          bool pop = await Navigator.push(
              context, MaterialPageRoute(builder: (context) {
            return MyHomePage();
          }));
          if (pop == true) {
            updateListView();
          }
        },
        child: Icon(
          Icons.add,
          size: 30.0,
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: scaler.getWidth(65.0),
                      height: 45.0,
                      //decoration: BoxDecoration(
                      //borderRadius: BorderRadius.circular(10.0),
                      //),
                      child: TextFormField(
                        onChanged: (val) {
                          setState(() {
                            query = val;
                          });
                        },
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10.0)
                            ),
                            suffixIcon: Icon(
                              Icons.search,
                              size: 30.0,
                            )),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.sort,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: Text("Sort"),
                                  elevation: 2.0,
                                  content: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10.0)),
                                    height: 220.0,
                                    child: Column(children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sort = "Latest";
                                                });
                                                updateListView();
                                                Navigator.pop(context);
                                              },
                                              child: ListTile(
                                                title:
                                                Text("Sort by Latest Task"),

                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sort = "Oldest";
                                                });
                                                updateListView();
                                                Navigator.pop(context);
                                              },
                                              child: ListTile(
                                                title:
                                                Text("Sort by Oldest Task"),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sort = "Title A";
                                                });
                                                updateListView();
                                                Navigator.pop(context);
                                              },
                                              child: ListTile(
                                                title: Text("Sort by Tile"),
                                                subtitle: Text("Desending"),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sort = "Title D";
                                                });
                                                updateListView();
                                                Navigator.pop(context);
                                              },
                                              child: ListTile(
                                                title: Text("Sort by Title"),
                                                subtitle: Text("Assending"),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sort = "Date A";
                                                });
                                                updateListView();
                                                Navigator.pop(context);
                                              },
                                              child: ListTile(
                                                title: Text("Sort by Date"),
                                                subtitle: Text("Assending"),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  sort = "Date D";
                                                });
                                                updateListView();
                                                Navigator.pop(context);
                                              },
                                              child: ListTile(
                                                title: Text("Sort by Date"),
                                                subtitle: Text("Desending"),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ]),
                                  ));
                            });
                      },
                      iconSize: 35.0,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                      iconSize: 35.0,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.only(left: 20.0, bottom: 30.0, top: 30.0),
                child: Text(
                  "Task",
                  style: TextStyle(color: Colors.white, fontSize: 30.0),
                ),
              ),
              query
                  .toLowerCase()
                  .isEmpty
                  ? FutureBuilder(
                  future: databaseHelper.getNoteList(sort),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return new Text('Loading...');
                      default:
                        NoteList = snapshot.data;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: GridView.builder(
                              //reverse: true,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10.0,
                                    mainAxisSpacing: 15,
                                    childAspectRatio:  MediaQuery.of(context).size.width /
                                        (MediaQuery.of(context).size.height)),
                                itemCount: NoteList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    clipBehavior: Clip.antiAlias,
                                    height: 10.0,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                    child: Slidable(
                                      actionPane: SlidableDrawerActionPane(),
                                      actionExtentRatio: 0.15,
                                      closeOnScroll: false,




                                      direction: Axis.vertical,
                                      actions: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: <Widget>[
                                            GestureDetector(
                                                onTap: () {
                                                    databaseHelper.deleteNote(
                                                        NoteList[index].id);
                                                    updateListView();
                                                },
                                                child: Icon(Icons.delete,color: Colors.white,)),
                                            GestureDetector(
                                                onTap: () {
                                                  final RenderBox box = context.findRenderObject();
                                                  Share.share("${NoteList[index].Title} on ${NoteList[index].Date} by ${DateFormat.jm().format(NoteList[index].Date) }\n ${NoteList[index].Description}",
                                                      subject: "Todo Task",
                                                      sharePositionOrigin:
                                                      box.localToGlobal(Offset.zero) &
                                                      box.size);
                                                },
                                                child: Icon(Icons.share,color: Colors.white,)),
                                          ],
                                        ),
                                      ],
                                      key: Key(NoteList[index].id.toString()),
                                      child: Notelist(
                                          NoteList[index].id,
                                          NoteList[index].Title,
                                          NoteList[index].Date,
                                          NoteList[index].category,
                                          NoteList[index].Reminder,
                                          NoteList[index].status,
                                          NoteList[index].Description),
                                    ),
                                  );
                                }),
                        );
                    }
                  })
                  : show(scaler)
            ],
          ),
        ],
      ),
    );
  }
}


