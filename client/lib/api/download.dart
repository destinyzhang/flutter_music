import 'package:dl_music/structs/song.dart';
import 'package:dl_music/storage/storage.dart';
import 'package:dl_music/api/music.dart';
import 'package:dl_music/structs/downloadresult.dart';
import 'package:dl_music/storage/storage.song.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';

typedef void DownloaderNotify(int status, Object parm1, Object parm2, Object parm3);

class Downloader {
  static Song _currentDownload;
  static List<DownloaderNotify> _listeners =   List<DownloaderNotify>();
  static CancelToken _cancelToken =   CancelToken();
  static double _count = 0;
  static double _total = 0;
  static double _countFlag = 0;
  static get downloading => _currentDownload != null;

  static get downProgress {
    if (_count <= _total && _total > 0)
      return _count / _total;
    return 0.0;
  }

  static void start() {
    _checkDownload();
  }

  static void addListener(DownloaderNotify lister) {
    if (lister == null) return;
    _listeners.add(lister);
  }

  static void removeListener(DownloaderNotify lister) {
    if (lister == null) return;
    _listeners.remove(lister);
  }

  static void cancelDownload() {
    if (!downloading)
      return;
    _currentDownload = null;
    _cancelToken?.cancel("cancel download");
    _cancelToken = null;
  }

  static void _onReceiveProgress(int count, int total) {
    _count = count.toDouble();
    _total = total.toDouble();
    //避免平凡更新
    if (_count - _countFlag >= total / 10) {
      _countFlag = _count;
      _notifyListener(0, null, null, null);
    }
  }

  static Future<Uint8List> _downloadBytes(String url) async {
    Uint8List bytes;
    try {
      _cancelToken =   CancelToken();
      Response response = await Dio().get(
        url,
        onReceiveProgress: _onReceiveProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
        cancelToken: _cancelToken,
      );
      bytes = Uint8List.fromList(response.data);
    } catch (e) {
      print("_downloadBytes e: " + e.toString());
    }
    _cancelToken = null;
    return bytes;
  }

  static void _notifyListener(int status, Object parm1, Object parm2,
      Object parm3) {
    //通知出去
    for (var lsn in _listeners) {
      try {
        lsn(status, parm1, parm2, parm3);
      } catch (e) {}
    }
  }

  static void _download(Song song) async {
    _currentDownload = song;
    String fileName = _currentDownload.getFileName();
    _notifyListener(0, null, null, null);
    int result = ErrCode.ErrCodeServer404;
    //判断文件是否存在
    if (!await Storage.checkAppFileExist(fileName)) {
      DownloadResult downlResult = await MusicApi.getDownloadURL(
          _currentDownload.dlid);
      //如果已经没有下载对象了
      if (_currentDownload == null)
        return;
      if (downlResult != null) {
        result = downlResult.errorcode;
        if (result == ErrCode.ErrCodeOk) {
          final bytes = await _downloadBytes(downlResult.url);
          if (bytes != null && _currentDownload != null) {
            if (await Storage.saveAppByteFile(fileName, bytes)) {
              if (_currentDownload != null) {
                _currentDownload.picpath = "${Storage.appPath}\/$fileName";
                SongStorage.songSave.addHead(_currentDownload);
                SongStorage.songSave.save();
              }
            } else
              result = ErrCode.ErrCodeSaveFail;
          } else
            result = ErrCode.ErrCodeDownloadFail;
        }
      }
    } else {
      if (_currentDownload != null) {
        result = ErrCode.ErrCodeOk;
        //文件已经存在
        if (!SongStorage.songSave.songExist(_currentDownload.dlid)) {
          _currentDownload.picpath = "${Storage.appPath}\/$fileName";
          SongStorage.songSave.addHead(_currentDownload);
          SongStorage.songSave.save();
        }
      }
    }
    _countFlag = _count = _total = 0;
    if (_currentDownload != null) {
      SongStorage.songDownload.remove(_currentDownload);
      if (result != ErrCode.ErrCodeOk)
        SongStorage.songDownload.addSong(_currentDownload);
      _notifyListener(1, _currentDownload?.name, result, null);
      _currentDownload = null;
      SongStorage.songDownload.save();
      _checkDownload();
    }
  }

  static bool isDownloadSong(Song song) {
    return _currentDownload != null && song.dlid == _currentDownload.dlid;
  }

  static void _checkDownload() async {
    if (downloading)
      return;
    Song song = SongStorage.songDownload.getSong(0);
    if (song != null)
      _download(song);
  }
}