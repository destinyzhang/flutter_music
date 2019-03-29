import 'package:flutter/material.dart';
import 'package:dl_music/structs/song.dart';
import 'package:dl_music/api/download.dart';
import 'package:dl_music/pages//player.dart';
import 'package:dl_music/api/player.dart';
import 'package:dl_music/storage/storage.song.dart';
import 'package:dl_music/storage/unit.dart';
import 'package:dl_music/pages/toast.dart';

class SongsPage extends StatefulWidget {
  SongsPage({Key key}) : super(key: key);
  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  @override
  void initState() {
    super.initState();
    Downloader.addListener(this.onDownloadLister);
    MiniPlayer.instance.addListener(_playerNotify);
  }

  void onDownloadLister(int status, Object parm1, Object parm2,
      Object parm3) {
    if (status == 1 && parm2 == 0)
      setState(() {});
  }

  void _playerNotify(NotifyValue value) {
    if (value == NotifyValue.songChange || value == NotifyValue.stateChange)
      setState(() {});
  }

  @override
  void dispose() {
    Downloader.removeListener(this.onDownloadLister);
    MiniPlayer.instance.removeListener(_playerNotify);
    super.dispose();
  }

  PopupMenuItem<int> _buildPopupMenuItem(String text, int id) {
    return   PopupMenuItem<int>(
        value: id,
        child: Text(text)
    );
  }

  void _onPopupMenuItemSelected(int value, Song song) {
    switch (value) {
      case 0:
        {
          SongInfo songInfo = SongInfo(songURL: song.picpath,
              songName: song.name,
              uniqueName: song.dlid,
              isLocal: true);
          MiniPlayer.instance.setProvider(SongStorage.songSave);
          MiniPlayer.instance.play(songInfo).then((value) {
            if (value < 0)
              ToastPage.show("${song.name}已删除，播放失败");
            setState(() {
              MiniPlayer.instance.songProvider?.seekSong(songInfo);
            });
          });
        }
        break;
      case 1:
        {
          List<ItemListDialog> list =   List<ItemListDialog>();
          SongStorage.sheetSave.sheets.forEach((sheet) {
            if (!sheet.songExist(song.dlid)) {
              ItemListDialog item = ItemListDialog();
              item.title = sheet.name;
              item.subTitle = "${sheet.songsNum}首歌";
              item.trailWidget =
                  IconButton(icon: Icon(Icons.add), onPressed: () {
                    if (!sheet.songExist(song.dlid)) {
                      sheet.addSong(song.dlid);
                      SongStorage.sheetSave.save();
                    }
                    if (Navigator.of(context).canPop())
                      Navigator.of(context).pop();
                  });
              list.add(item);
            }
          });
          if (list.length > 0)
            ToastPage.showListDialog(context, list);
        }
        break;
      case 2:
        {
          ToastPage.showAlertDialog(
              context, "删除${song.name}", okText: "删除", okCallback: () {
            SongStorage.songSave.deleteSongFile(song).then((value) {
              setState(() {});
            });
          });
        }
        break;
    }
  }

  List<PopupMenuItem<int>> _buildPopupMenuItems(String dlid) {
    List<PopupMenuItem<int>> list = List<PopupMenuItem<int>>();
    list.add(_buildPopupMenuItem("播放", 0));
    if (SongStorage.sheetSave.sheets.length > 0 && !SongStorage.sheetSave.sheetsHaveSong(dlid))
      list.add(_buildPopupMenuItem("加入歌单", 1));
    list.add(_buildPopupMenuItem("删除", 2));
    return list;
  }

  Widget _listBuilder(BuildContext context, int index) {
    Song song = SongStorage.songSave.getSong(index);
    if (song == null)
      return null;
    return ListTile(
      selected: MiniPlayer.instance.url == song.picpath,
      title: Text(song.name),
      subtitle: Text("${song.singer} ${song.getTime()} ${song.getSize()}"),
      trailing: MiniPlayer.instance.url == song.picpath
          ? Icon(
          Icons.play_circle_filled, color: Unit.instance.styleColor)
          : PopupMenuButton(
        tooltip: '下拉菜单',
        onSelected: (int value) => _onPopupMenuItemSelected(value, song),
        itemBuilder: (BuildContext context) => _buildPopupMenuItems(song.dlid),
        icon: Icon(Icons.menu),),
    );
  }

  Widget _buildBottomNavigationBar() {
    if (SongStorage.songSave.songs.length == 0)
      return null;
    if (MiniPlayer.instance.songProvider != SongStorage.songSave)
      return null;
    return PlayerWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: _listBuilder,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
