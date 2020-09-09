import 'dart:typed_data';

import 'package:custom_switch_button/custom_switch_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/main.dart';

import 'utils/model.dart';
class Notelist extends StatefulWidget {
  int id;
  String title;
  String desc;
  DateTime date;
  String category;
  int reminder;
  String status;
  Notelist(this.id,this.title,this.date,this.category,this.reminder,this.status,[this.desc]);
  @override
  _NotelistState createState() => _NotelistState();
}

class _NotelistState extends State<Notelist> with SingleTickerProviderStateMixin {

  bool value;
  int sqlValue;
  var customFormat2 = DateFormat('MM-dd');
  DatabaseHelper databaseHelper = DatabaseHelper();
  bool val(){
    if(widget.reminder==1){
      setState(() {
        value=true;
      });
    }
    else if(widget.reminder==0){
      setState(() {
        value=false;
        //sqlValue=0;
      });
    }
    return value;
  }

  onChanged() {
    setState(() {
      value = !value;
    });
    if (value) {
      setState(() {
        widget.reminder = 1;
      });
      if(DateTime.now().isBefore(widget.date)||DateTime.now().isAtSameMomentAs(widget.date)){


        _scheduleNotification();
      }

    }
    else if(!value){
      setState(() {
        widget.reminder = 0;
      });
      _cancelNotification();
    }
    databaseHelper.updateNote(Notes.withId(widget.id,widget.title,widget.date,widget.category, widget.status, widget.reminder,widget.desc));

    print(widget.reminder);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 20.0,
                          )),
                  Container(
                    height: scaler.getHeight(5.5) ,
                    child: Center(
                          child: Text(
                            "${widget.title}",
                            style: TextStyle(color: Colors.greenAccent, fontSize: scaler.getTextSize(14)),
                          ),
                      ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: scaler.getWidth(40)),
                          height: scaler.getHeight(8),
                          child: Text("${widget.desc}", style: TextStyle(color: Colors.black, fontSize:scaler.getTextSize(12),)),
                        ),

                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical:5.0),
                                          child: Text("Date"),
                                        ),
                                        Text("${customFormat2.format(widget.date)}"),
                                      ],
                                    ),
                                  Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical:5.0),
                                          child: Text("Time"),
                                        ),
                                        Text("${DateFormat.jm().format(widget.date)}"),
                                      ],
                                    ),
                                  Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical:5.0),
                                          child: Text("Category"),
                                        ),
                                        Text("${widget.category}"),
                                      ],
                                    ),
                                ],
                              ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Divider(
                      thickness: 2.0,
                      color: Colors.yellow,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Reminder"),
                      GestureDetector(
                        onTap: (){
                          onChanged();
                        },
                        child: CustomSwitchButton(
                          checked: val(),
                          unCheckedColor:Colors.blueGrey,
                          backgroundColor:widget.reminder==1?Colors.yellow[300]:Colors.grey,
                          checkedColor:Colors.yellowAccent,
                          animationDuration: Duration(milliseconds: 100),
                          ///activeColor: Colors.yellow,
                          //
//                        activeTrackColor: _color1,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Status"),
                        Container(
                          decoration: BoxDecoration(
                            //border:Border.all(color: widget.status=="Not completed"?Colors.greenAccent:null),
                            borderRadius: BorderRadius.circular(10.0),
                            color: widget.status=="Not completed"?Colors.greenAccent:Colors.yellowAccent
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Center(child: Text(widget.status),),
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      if(widget.status=="Not completed"){
                        setState(() {
                          widget.status="Completed";
                          databaseHelper.updateNote(Notes.withId(widget.id,widget.title,widget.date, widget.category, widget.status, widget.reminder,widget.desc));
                        });
                      }

                    },
                    child: Center(
                      child:Container(
                          decoration: BoxDecoration(
                            border:Border.all(color: widget.status=="Not completed"?Colors.greenAccent:Colors.black38),
                              borderRadius: BorderRadius.circular(10.0),
                              color: widget.status=="Not completed"?Colors.transparent:Colors.black38
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Complete Task",style: TextStyle(color:widget.status=="Not completed"?Colors.black:Colors.white ),),
                          ),
                    )),
                  )

                ],
              ),
            ),
          );
  }
  Future<void> _scheduleNotification() async {
    var scheduledNotificationDateTime =
    widget.date;
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        when:5,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics =
    IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        widget.id,
        widget.title,
        widget.desc,
        scheduledNotificationDateTime,
        platformChannelSpecifics);
    print("done");
  }
  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(widget.id);
  }
}
