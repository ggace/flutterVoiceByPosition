import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animator/animator.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilderExample(),
    );
  }
}


class StreamBuilderExample extends StatefulWidget {
  const StreamBuilderExample({Key? key}) : super(key : key);
  @override
  StreamBuilderExampleState createState() => StreamBuilderExampleState();
}

class StreamBuilderExampleState extends State<StreamBuilderExample> {
  bool paused = false;
  bool doload = false;
  final FlutterTts tts = FlutterTts();
  final text = "Here is a dangerous place. Be careful";
  Position? location;
  SharedPreferences? prefs;
  double? latitude;
  double? longitude;

  final scale = 0.00003;

  StreamBuilderExampleState() {
    tts.setLanguage('en');
    tts.setSpeechRate(0.5);

    setPref();
  }

  void setPref() async{
    prefs = await SharedPreferences.getInstance();
  }

  final Stream<int> periodicStream = Stream.periodic(
      const Duration(milliseconds: 100), (i) => i);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder(
          stream: this.periodicStream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {

              doload = true;
              if(doload){
                _fetch1().then((value) {
                  location= value;
                } );
              }

              if(prefs != null){
                latitude = prefs!.getDouble("latitude");
                longitude = prefs!.getDouble("longitude");
              }

              if(location != null && latitude != null && longitude != null){
                if(location!.latitude >= latitude!-scale
                    && location!.latitude <= latitude!+scale
                    && location!.longitude >= longitude!-scale
                    && location!.longitude <= longitude!+scale

                ){
                  if(!paused){
                    tts.speak(text);
                    this.paused = true;
                    print("true");
                  }

                }
                else{
                  this.paused = false;

                  print("false");
                }
              }





            }
            return Center(
                child: Column(

              mainAxisSize: MainAxisSize.min,
              
              children: <Widget>[

                  Card(child: buildTimerUi()),
                ElevatedButton(
                    onPressed: () {
                      _fetch1().then((value) {
                        location = value;
                        latitude = value.latitude;
                        longitude = value.longitude;
                        if(prefs != null){
                          prefs!.setDouble("latitude", latitude!);
                          prefs!.setDouble("longitude", longitude!);

                        }
                        paused = false;

                      } );
                    },
                    child: Text('setPosition')),
                Text('latitude : $latitude, longtitude : $longitude')
              ],
            ));
          },
        )
    );
  }

  Widget buildTimerUi() {
    return Column(
      children: [
        Text(
          '$location',

        ),

      ],
    );
  }
  Future<Position> _fetch1() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    doload = false;
    return position;
  }
}