import 'package:flutter/material.dart';
import 'home.dart';
import 'package:dl_music/storage/storage.dart';
import 'package:dl_music/api/music.dart';
import 'package:dl_music/storage/unit.dart';
import 'package:flutter/services.dart';

void main() {
  //强制竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp({ Key key }) : super(key: key){
    Storage.init();
    MusicApi.getSeverUrl(true);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Unit.instance.styleColor,
      ),
      home: SafeArea(child:MyHomePage()),
    );
  }
}
