import 'package:flutter/material.dart';
import 'package:dl_music/storage/storage.song.dart';
import 'package:dl_music/structs/song.sheet.dart';
import 'package:dl_music/storage/unit.dart';
import 'package:dl_music/pages/toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dl_music/api/player.dart';
import 'package:dl_music/pages//player.dart';
import 'package:dl_music/structs/song.dart';
import 'package:dl_widget/dl_draglist.dart';

class SongSheetPage extends StatefulWidget {
  SongSheetPage({Key key}) : super(key: key);

  @override
  _SongSheetPageState createState() => _SongSheetPageState();
}

class _SongSheetPageState extends State<SongSheetPage> {
  void _onPopupMenuItemSelected(int value, SongSheet sheet) {
    switch (value) {
      case 0:
        {
          MiniPlayer.instance.setProvider(sheet);
          MiniPlayer.instance.playerProvider().then((value) => setState(() {}));
        }
        break;
      case 1:
        {
          ToastPage.showEditDialog(context, text: sheet.name,
              okCallback: (name) {
            setState(() {
              SongStorage.sheetSave.renameSheet(sheet.name, name);
            });
          }, check: (name) {
            if (name.trim().length == 0 || name == sheet.name) return false;
            if (SongStorage.sheetSave.nameExist(name)) {
              ToastPage.show("名称已存在", gravity: ToastGravity.TOP);
              return false;
            }
            return true;
          });
        }
        break;
      case 2:
        {
          ToastPage.showAlertDialog(context, "删除${sheet.name}", okText: "删除",
              okCallback: () {
            setState(() {
              SongStorage.sheetSave.removeSheet(sheet.name);
            });
          });
        }
        break;
      case 3:
        {
          VVoidCallBack vvCallBack;
          VVVoidCallBack vvvCallBack = (value) => vvCallBack = value;
          WidgetBuilder _builder = (BuildContext context) {
            List<ListTile> listChild = List<ListTile>();
            sheet.songs.forEach((dlid) {
              Song song = SongStorage.songSave.findSong(dlid);
              if (song == null) return;
              listChild.add(ListTile(
                title: Text(song.name),
                subtitle:
                    Text("${song.singer} ${song.getTime()} ${song.getSize()}"),
                trailing: PopupMenuButton(
                  tooltip: '下拉菜单',
                  onSelected: (int value) {
                    if (value == 0) {
                      if (MiniPlayer.instance.uniqueName == dlid) return;
                      Song song = SongStorage.songSave.findSong(dlid);
                      if (song != null) {
                        MiniPlayer.instance.setProvider(sheet);
                        MiniPlayer.instance.play(SongInfo(
                            songURL: song.picpath,
                            songName: song.name,
                            uniqueName: song.dlid,
                            isLocal: true));
                        setState(() {});
                      }
                    } else if (value == 1) {
                      if (sheet.remove(dlid)) {
                        if (vvCallBack != null) vvCallBack(() {});
                        setState(() {});
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuItem<int>>[
                      _buildPopupMenuItem("播放", 0),
                      _buildPopupMenuItem("删除", 1),
                    ];
                  },
                  icon: Icon(Icons.menu),
                ),
              ));
            });

            return DragList.buildFromList(
                list: listChild,
                onDragEnd: (from, to) {
                  sheet.songs.insert(to, sheet.songs.removeAt(from));
                  SongStorage.sheetSave.save();
                  if (vvCallBack != null) vvCallBack(() {});
                });
          };
          ToastPage.showCustomDialog(context, _builder, vvvCallBack);
        }
        break;
    }
  }

  PopupMenuItem<int> _buildPopupMenuItem(String text, int id) {
    return PopupMenuItem<int>(value: id, child: Text(text));
  }

  List<PopupMenuItem<int>> _buildPopupMenuItems(SongSheet sheet) {
    List<PopupMenuItem<int>> list = List<PopupMenuItem<int>>();
    if (MiniPlayer.instance.songProvider != sheet)
      list.add(_buildPopupMenuItem("播放", 0));
    list.add(_buildPopupMenuItem("改名", 1));
    if (sheet.songsNum > 0) list.add(_buildPopupMenuItem("编辑", 3));
    if (MiniPlayer.instance.songProvider != sheet)
      list.add(_buildPopupMenuItem("删除", 2));
    return list;
  }

  Widget _listBuilder(BuildContext context, int index) {
    SongSheet sheet = SongStorage.sheetSave.getSheet(index);
    if (sheet == null) return null;
    return ListTile(
      title: Text(sheet.name),
      selected: MiniPlayer.instance.songProvider == sheet,
      subtitle: Text("${sheet.songsNum}首歌"),
      trailing: PopupMenuButton(
        tooltip: '下拉菜单',
        onSelected: (int value) => _onPopupMenuItemSelected(value, sheet),
        itemBuilder: (BuildContext context) {
          return _buildPopupMenuItems(sheet);
        },
        icon: Icon(Icons.menu),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    if (SongStorage.sheetSave.sheets.length == 0) return null;
    for (var sheet in SongStorage.sheetSave.sheets)
      if (sheet == MiniPlayer.instance.songProvider) return PlayerWidget();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Unit.instance.styleColor,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              tooltip: '新建歌单',
              onPressed: () {
                ToastPage.showEditDialog(context, hintText: "输入名称",
                    okCallback: (name) {
                  setState(() {
                    SongStorage.sheetSave.addNewSheet(name);
                  });
                }, check: (name) {
                  if (name.trim().length == 0) return false;
                  if (SongStorage.sheetSave.nameExist(name)) {
                    ToastPage.show("名称已存在", gravity: ToastGravity.TOP);
                    return false;
                  }
                  return true;
                });
              }),
        ],
      ),
      body: ListView.builder(
        itemBuilder: _listBuilder,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
