import 'package:flutter/material.dart';
import 'package:dl_music/structs/song.dart';
import 'package:dl_music/api/download.dart';
import 'package:dl_music/pages/toast.dart';
import 'package:dl_music/api/music.dart';
import 'package:dl_music/storage/unit.dart';
import 'package:dl_music/storage/storage.song.dart';

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
    return   PopupMenuItem<int>(
        value: id,
        child: Text(text)
    );
  }

  void _onPopupMenuItemSelected(int value, Song song) {
    switch (value) {
      case 0:
        {
          if (Downloader.isDownloadSong(song))
            return;
          if (SongStorage.songDownload.insertTo(
              song, Downloader.downloading ? 1 : 0))
            setState(() {});
        }
        break;
      case 1:
        {
          ToastPage.showAlertDialog(
              context, "删除${song.name}", okText: "删除", okCallback: () {
            if (!Downloader.isDownloadSong(song)) {
              if (SongStorage.songDownload.remove(song))
                setState(() {});
            }
          });
        }
        break;
    }
  }

  Widget _listBuilder(BuildContext context, int index) {
    Song song = SongStorage.songDownload.getSong(index);
    if (song == null)
      return null;
    if (Downloader.isDownloadSong(song)) {
      return ListTile(
        title: Text(
            song.name),
        selected: true,
        subtitle: Text("${song.singer} ${song.getTime()} ${song.getSize()}"),
        trailing:   Stack(
          children: [
              CircularProgressIndicator(
              value: 1.0,
              valueColor:   AlwaysStoppedAnimation(
                  Unit.instance.backColorTwo),
            ),
              CircularProgressIndicator(
              value: Downloader.downProgress,
              valueColor:   AlwaysStoppedAnimation(Unit.instance.playerColor),
            ),
          ],
        ),
      );
    }
    return ListTile(
      title: Text(
          song.name),
      subtitle: Text("${song.singer} ${song.getTime()} ${song.getSize()}"),
      trailing: PopupMenuButton(
        tooltip: '下拉菜单',
        onSelected: (int value) => _onPopupMenuItemSelected(value, song),
        itemBuilder: (BuildContext context) {
          return <PopupMenuItem<int>>[
            _buildPopupMenuItem("优先下载", 0),
            _buildPopupMenuItem("删除", 1),
          ];
        }, icon: Icon(Icons.menu),),
    );
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
        ToastPage.showAlertDialog(
            context, "确定清空下载列表？", okText: "清空", okCallback: () {
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
      body: ListView.builder(
        itemBuilder: _listBuilder,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
