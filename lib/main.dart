import 'dart:typed_data';

import 'package:custom_switch_button/custom_switch_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:todo_app/notespage.dart';
import 'package:todo_app/utils/model.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload);
      });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Notepage(),
      );
  }
}

class MyHomePage extends StatefulWidget{
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final MethodChannel platform =
  MethodChannel('crossingthestreams.io/resourceResolver');

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Notepage()
                  ),
                );
              },
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });
  }
  Animation animation;
  AnimationController _controller;
  TextEditingController controller=TextEditingController();
  String category;
  TextEditingController controller3=TextEditingController();
  int sqlValue = 0;
  bool value = false;
  Color _color1 = Colors.yellowAccent;
  Color _color2 = Colors.blueGrey;
  Color _color3 = Colors.greenAccent;
  Color _color4 = Colors.red;
  var date;
  DateTime currentDate = DateTime.now();

 var currentTime=TimeOfDay.now();
  var customFormat = DateFormat('dd-MM-yyyy');

  DateTime notify;
  var insert= DatabaseHelper();

  Date() async {
    var pick =await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2050));
    if(pick!=null&&pick!=currentDate){
      setState(() {
        currentDate=pick;
      });
    }

  }
  Time() async {
    var pick = await showTimePicker(context: context, initialTime: currentTime);
    if (pick != null && pick != currentTime) {
      setState(() {
        currentTime = pick;
      });
    }
  }

  onChanged() {
    setState(() {
      value=!value;
    });
    if (value) {
      setState(() {
        sqlValue = 1;
      });
    }
    else if(!value){
      setState(() {
        sqlValue=0;
      });
    }
    print(sqlValue);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notify=DateTime(currentDate.year,currentDate.month,currentDate.day,currentTime.hour,currentTime.minute);
    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    _controller=AnimationController(duration: Duration(milliseconds: 900),vsync: this);
    animation=Tween(begin:-1.0,end:0.0 ).animate(CurvedAnimation(parent: _controller, curve:Curves.easeIn));
    _controller.forward();
  }
  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.translationValues(animation.value*MediaQuery.of(context).size.width, 0, 0),
          child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              centerTitle: true,
              leading: GestureDetector(
                onTap: (){
                  Navigator.pop(context,false);
                },
                child: Icon(
                  Icons.keyboard_backspace,
                  size: 30.0,
                  color: Colors.black,
                ),
              ),
              title: Text(
                "Timed",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            body:SingleChildScrollView(
              child: Form(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0,0.0,20.0,0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: scaler.getHeight(3),
                          ),
                          Text(
                            "Add New Task",
                            style: TextStyle(color: Colors.black54, fontSize: 30.0),
                          ),
                          SizedBox(height: scaler.getHeight(3),),
                          TextFormField(
                              controller:controller ,
                              decoration: InputDecoration(
                                hintText: "Title",
                              ),
                            ),
                          SizedBox(height: scaler.getHeight(3),),
                          GestureDetector(
                                onTap: ()async {
                                 await Date();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    width: 1.0,color: Colors.blueGrey
                                  ))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Date"),
                                      SizedBox(
                                        height:scaler.getHeight(0.05),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("${customFormat.format(currentDate)}"),
                                          Icon(
                                            Icons.date_range,
                                            size: 30.0,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          //SizedBox(height: 30.0,),
                          SizedBox(height: scaler.getHeight(3),),
                          GestureDetector(
                                onTap: ()async {
                                  await Time();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                            width: 1.0,color: Colors.blueGrey
                                          ))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Time"),
                                      SizedBox(
                                        height: scaler.getHeight(0.05),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("${currentTime.format(context)}"),
                                          Icon(
                                            Icons.access_time,
                                            size: 30.0,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          SizedBox(height: scaler.getHeight(3),),
                          //SizedBox(height: 30.0,),

                          TextFormField(
                              controller: controller3,
                              maxLength: 50,
                              decoration: InputDecoration(
                                hintText: "Description",
                              ),
                            ),
                          //SizedBox(height: 30.0,),
                          SizedBox(height: scaler.getHeight(3),),
                          Text("select Category"),
                          SizedBox(
                            height:scaler.getHeight(2)
                          ),
                          Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      category="read";
                                    });
                                  },
                                  child: Container(
                                      width: scaler.getWidth(19),
                                      height: 30.0,
                                      decoration: BoxDecoration(
                                          color: _color1,
                                          borderRadius: BorderRadius.circular(10.0)),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Read"),
                                        ),
                                      ),
                                    ),
                                ),
                                SizedBox(width: scaler.getWidth(4),),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      category="cooking";
                                    });
                                  },
                                  child:Container(
                                      width: scaler.getWidth(19),
                                      height: 30.0,
                                      decoration: BoxDecoration(
                                          color: _color2,
                                          borderRadius: BorderRadius.circular(10.0)),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("cooking"),
                                        ),
                                      ),
                                    ),
                                ),
                                SizedBox(width: scaler.getWidth(4),),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      category="Games";
                                    });
                                  },
                                  child:Container(
                                      width:scaler.getWidth(19),
                                      height: 30.0,
                                      decoration: BoxDecoration(
                                          color: _color3,
                                          borderRadius: BorderRadius.circular(10.0)),
                                      child: Center(
                                        child: Text("Games"),
                                      ),
                                    ),
                                ),
                                SizedBox(width: scaler.getWidth(4),),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      category="Laundry";
                                    });
                                  },
                                  child: Container(
                                    width:scaler.getWidth(19),
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                        color: _color4,
                                        borderRadius: BorderRadius.circular(10.0)),
                                    child: Center(
                                      child: Text("Laundry"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: scaler.getHeight(4),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.greenAccent,
                                    ),
                                    child: Icon(
                                      Icons.notifications_none,
                                      color: Colors.white,
                                      size: 30.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left:4.0),
                                    child: Text("Remind me"),
                                  )
                                ],
                              ),
                              GestureDetector(
                                onTap: (){
                                  onChanged();
                                },
                                child: CustomSwitchButton(
                                  checked: value,

                                  unCheckedColor:Colors.grey,
                                    backgroundColor:Colors.white,
                                    checkedColor:Colors.yellow,
                                  animationDuration: Duration(milliseconds: 400),
                                  ///activeColor: Colors.yellow,
                                  //
//                        activeTrackColor: _color1,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: scaler.getHeight(8),),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  date= DateTime(currentDate.year,currentDate.month,currentDate.day,currentTime.hour,currentTime.minute,0);
                                });

                                Notes note = Notes(controller.text,date, category,
                                        "Not completed", sqlValue,controller3.text);

                                await insert.insertNote(note);
                                if(value){
                                  await _scheduleNotification();
                                }




                                Navigator.pop(context,true);


                               //return BlocProvider.of<Foodbloc>(context).add(Foodevent.add(insert));



                                print("ok");
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom:12.0),
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  width: 200.0,
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.circular(10.0)),
                                  child: Center(
                                    child: Text(
                                      "Create Task",
                                      style:
                                          TextStyle(color: Colors.white, fontSize: 20.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        );
      }
    );
  }
  Future<void> _scheduleNotification() async {
    var scheduledNotificationDateTime =date;
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
        ledOffMs: 500,);
    var iOSPlatformChannelSpecifics =
    IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      0,
        controller.text,
        controller3.text,
        scheduledNotificationDateTime,
        platformChannelSpecifics);
    print(currentTime.hourOfPeriod);
  }
}
