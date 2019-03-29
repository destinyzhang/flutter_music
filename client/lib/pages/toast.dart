import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart' ;
import 'package:dl_music/storage/unit.dart';
typedef StringCallback = void Function(String value);
typedef ObjectCallback = bool Function(Object value);
typedef StringCheck = bool Function(String value);
typedef VVoidCallBack = void Function(VoidCallback value);
typedef VVVoidCallBack = void Function(VVoidCallBack value);

 class ItemListDialog {
   String title;
   String subTitle;
   Widget trailWidget;
 }

class CustomDialog extends StatefulWidget {
   final WidgetBuilder _bodyBuilder;
   final VVVoidCallBack _callBack;
   CustomDialog(this._bodyBuilder,this._callBack):super();
  @override
  _CustomDialogState createState() => _CustomDialogState(_bodyBuilder,_callBack);
}

class _CustomDialogState extends State<CustomDialog> {
  WidgetBuilder _bodyBuilder;
  VVVoidCallBack _callBack;
  _CustomDialogState(this._bodyBuilder,this._callBack);
  @override
  void initState() {
    super.initState();
    this._callBack(this.setState);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: _bodyBuilder(context),
    );
  }
}

class ToastPage {
  static void show(String msg,
      {Color style, ToastGravity gravity }) {
    if (Unit.instance.appState == AppLifecycleState.paused)
      return;
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: gravity ?? ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: style ?? Unit.instance.styleColor,
        textColor: Unit.instance.backColorOne,
        fontSize: 16.0
    );
  }
  //_callBackShowSetState会将对话框setState函数暴露出去，外面可更新对话框
  static void showCustomDialog(BuildContext context, WidgetBuilder _builder,
      VVVoidCallBack _callBackShowSetState) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(_builder, _callBackShowSetState),
    );
  }

  static void showListDialog(BuildContext context, List<ItemListDialog> items) {
    IndexedWidgetBuilder itemBuilder = (BuildContext context, int index) {
      if (index >= items.length)
        return null;
      ItemListDialog item = items[index];
      return ListTile(
        title: Text(item.title ?? ""),
        subtitle: Text(item.subTitle ?? ""),
        trailing: item.trailWidget,
      );
    };
    showDialog(
      context: context,
      builder: (_) =>
          Scaffold(
              appBar: AppBar(),
              body: ListView.builder(
                  itemBuilder: itemBuilder, itemCount: items.length)
          ),
    );
  }

  static void showAlertDialog(BuildContext context, String msg,
      {String title, String okText, String cancelText, VoidCallback okCallback, VoidCallback cancelCallBack}) {
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
                title: title == null ? null : Center(heightFactor: 1.0,
                    child: Text(
                      title, style: Unit.instance.getUnitTextStyle(24.0),)),
                content: Center(
                  heightFactor: 1.0,
                  child: Text(
                    msg, style: Unit.instance.getUnitTextStyle(24.0),),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(okText ?? "确认",
                      style: Unit.instance.getUnitTextStyle(16.0),),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (okCallback != null)
                        okCallback();
                    },),
                  FlatButton(
                    child: Text(cancelText ?? "取消",
                      style: Unit.instance.getUnitTextStyle(16.0),),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (cancelCallBack != null)
                        cancelCallBack();
                    },)
                ]

            ));
  }

  static showEditDialog(BuildContext context,
      {String text, StringCallback okCallback, String hintText, StringCheck check, VoidCallback cancelCallBack}) {
    TextEditingController _editDialogCtl = TextEditingController();
    _editDialogCtl.text = text ?? "";
    showDialog(
      context: context,
      builder: (_) {
        return Material(
          child: Card(
            child: Column(
              children: <Widget>[
                TextField(
                  maxLength: 20,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(gapPadding: 0.0),
                    hintText: hintText ?? "",
                    prefixIcon: Icon(Icons.queue_music),
                  ),
                  controller: _editDialogCtl,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text("确认",
                        style: Unit.instance.getUnitTextStyle(20.0),),
                      onPressed: () {
                        if (check != null && !check(_editDialogCtl.text))
                          return;
                        Navigator.of(context).pop();
                        if (okCallback != null)
                          okCallback(_editDialogCtl.text);
                      },),
                    FlatButton(
                      child: Text("取消",
                          style: Unit.instance.getUnitTextStyle(20.0)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (cancelCallBack != null)
                          cancelCallBack();
                      },)
                  ],
                ),
              ],
            ),
          ),);
      },
    );
  }
}
