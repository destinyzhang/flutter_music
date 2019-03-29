import 'package:flutter/material.dart';
class Unit with WidgetsBindingObserver {
 final bool inProduction = bool.fromEnvironment("dart.vm.product");
 final Color styleColor = Colors.blue;
 final Color backColorOne = Colors.white;
 final Color backColorTwo = Colors.grey;
 final Color playerColor =  Colors.blue;

 TextStyle getUnitTextStyle(double fontSize) => TextStyle(color: styleColor, fontSize: fontSize);

 AppLifecycleState _appState;

 get appState => _appState;
 static Unit _instance;

 static Unit get instance {
  if (_instance == null)
   _instance = Unit();
  return _instance;
 }

 @override
 void didChangeAppLifecycleState(AppLifecycleState state) {
  _appState = state;
 }
}