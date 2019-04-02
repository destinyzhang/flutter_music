import 'package:flutter/material.dart';
import 'package:dl_music/structs/song.dart';
import 'package:dl_music/api/download.dart';
import 'package:dl_music/pages/toast.dart';
import 'package:dl_music/api/music.dart';
import 'package:dl_music/storage/unit.dart';
import 'package:dl_music/storage/storage.song.dart';
import 'package:dl_widget/dl_draglist.dart';

class DownloadPage extends StatefulWidget {
  DownloadPage({Key key}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  void initState() {
    super.initState();
    Downloader.addListener(this.onDownloadLister);
  }

  void onDownloadLister(int status, Object parm1, Object parm2, Object parm3) {
    setState(() {
      if (status == 1 && parm2 != ErrCode.ErrCodeOk) {
        ToastPage.show(
            "${parm1?.toString() ?? ""}下载失败:" + ErrCode.errMsg(parm2 as int));
      }
    });
  }

  @override
  void dispose() {
    Downloader.removeListener(this.onDownloadLister);
    super.dispose();
  }

  PopupMenuItem<int> _buildPopupMenuItem(String text, int id) {
    return PopupMenuItem<int>(value: id, child: Text(text));
  }

  void _onPopupMenuItemSelected(Song song) {
    ToastPage.showAlertDialog(context, "删除${song.name}", okText: "删除",
        okCallback: () {
      if (!Downloader.isDownloadSong(song)) {
        if (SongStorage.songDownload.remove(song)) setState(() {});
      }
    });
  }

  Data2Widget<Song> _listBuilder(BuildContext context, int index) {
    Song song = SongStorage.songDownload.getSong(index);
    if (song == null) return null;
    Widget widget;
    if (Downloader.isDownloadSong(song)) {
      widget = ListTile(
        title: Text(song.name),
        selected: true,
        subtitle: Text("${song.singer} ${song.getTime()} ${song.getSize()}"),
        trailing: Stack(
          children: [
            CircularProgressIndicator(
              value: 1.0,
              valueColor: AlwaysStoppedAnimation(Unit.instance.backColorTwo),
            ),
            CircularProgressIndicator(
              value: Downloader.downProgress,
              valueColor: AlwaysStoppedAnimation(Unit.instance.playerColor),
            ),
          ],
        ),
      );
    } else {
      widget = ListTile(
        title: Text(song.name),
        subtitle: Text("${song.singer} ${song.getTime()} ${song.getSize()}"),
        trailing: PopupMenuButton(
          tooltip: '下拉菜单',
          onSelected: (int value) => _onPopupMenuItemSelected(song),
          itemBuilder: (BuildContext context) {
            return <PopupMenuItem<int>>[
              _buildPopupMenuItem("删除", 0),
            ];
          },
          icon: Icon(Icons.menu),
        ),
      );
    }
    return Data2Widget<Song>(data: song, widget: widget);
  }

  void _onBottomNavigationBarTap(int value) {
    switch (value) {
      case 0:
        setState(() {
          Downloader.downloading
              ? Downloader.cancelDownload()
              : Downloader.start();
        });
        break;
      case 1:
        ToastPage.showAlertDialog(context, "确定清空下载列表？", okText: "清空",
            okCallback: () {
          setState(() {
            Downloader.cancelDownload();
            SongStorage.songDownload.clear();
          });
        });
        break;
    }
  }

  Widget _buildBottomNavigationBar() {
    if (SongStorage.songDownload.getSong(0) != null) {
      return BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Downloader.downloading ? Icons.stop : Icons.play_arrow,
                color: Unit.instance.styleColor,
              ),
              title: Text(
                Downloader.downloading ? "停止下载" : "开始下载",
                style: TextStyle(color: Unit.instance.styleColor),
              )),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.delete,
                color: Unit.instance.styleColor,
              ),
              title: Text(
                '清空下载',
                style: TextStyle(color: Unit.instance.styleColor),
              )),
        ],
        type: BottomNavigationBarType.fixed,
        iconSize: 12,
        onTap: (idx) => _onBottomNavigationBarTap(idx),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DragList<Song>.buildFromBuilder(
        widgetBuilder: _listBuilder,
        updateDragDataIdx: (data) =>
            SongStorage.songDownload.songs.indexWhere((s) => s == data),
        onDragEnd: (from, to) => SongStorage.songDownload
            .insertTo(SongStorage.songDownload.getSong(from), to),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
