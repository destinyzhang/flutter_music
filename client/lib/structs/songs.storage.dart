import 'package:json_annotation/json_annotation.dart';
import 'package:dl_music/structs/song.dart';
import 'package:dl_music/storage/storage.dart';
import 'dart:convert';
import 'dart:math';
import 'package:dl_music/api/player.dart';
part 'package:dl_music/structs/songs.storage.g.dart';

@JsonSerializable()
class SongsStorage extends ISongProvider {
  String _curPlayerSong = "";
  void seekSong(SongInfo song) {
    int idx = songs.indexWhere((s) => s.dlid == song.uniqueName);
    if (idx >= 0)
      _curPlayerSong =  song.uniqueName;
  }

 void inValidSong(SongInfo song) {
   int idx = songs.indexWhere((s) => s.dlid == song.uniqueName);
   if (idx >= 0) {
     songs.removeAt(idx);
     save();
   }
 }

  SongInfo getNextSong(PlayMode mode,bool next) {
    var count = songs.length;
    if (count == 0) return null;
    int idx = 0;
    switch (mode) {
      case PlayMode.random_source:
        {
          idx = Random().nextInt(count) % count;
        }
        break;
      case PlayMode.circle_provider:
        {
          idx = songs.indexWhere((song) => song.dlid == _curPlayerSong);
          if (next) {
            ++idx;
            if (idx >= count)
              idx = 0;
          } else {
            --idx;
            if (idx < 0)
              idx = songs.length - 1;
          }
        }
        break;
      case PlayMode.circle_song:
        return null;
    }
    Song song = songs[idx];
    _curPlayerSong = song.dlid;
    return SongInfo(songURL: song.picpath,
        songName: song.name,
        uniqueName: song.dlid,
        isLocal: true);
  }

  String _savePath;
  List<Song> songs;

  SongsStorage({this.songs});

  factory SongsStorage.fromSavePath(String path){
    SongsStorage storage = SongsStorage(songs:   List<Song>());
    storage._savePath = path;
    return storage;
  }

  factory SongsStorage.fromJson(Map<String, dynamic> json) =>
      _$SongsStorageFromJson(json);

  Map<String, dynamic> toJson() => _$SongsStorageToJson(this);

  void addSong(Song song) => songs.add(song);

  void addHead(Song song) => songs.insert(0, song);

  bool insertTo(Song song, int to) {
    if (to < 0) return false;
    int from = songs.indexWhere((s) {
      return s.dlid == song.dlid;
    });
    if (from == to || from < 0)
      return false;
    removeAt(from);
    if (to >= songs.length)
      songs.add(song);
    else
      songs.insert(to, song);
    return true;
  }

  Song findSong(String dlid) {
    return songs.firstWhere((s) {
      return s.dlid == dlid;
    }, orElse: () => null);
  }

  bool songExist(String dlid) {
    return songs.indexWhere((s) {
      return s.dlid == dlid;
    }) >= 0;
  }

  bool remove(Song song) {
    return songs.remove(song);
  }

  Song removeAt(int index) {
    if (index < 0 || index >= songs.length)
      return null;
    return songs.removeAt(index);
  }

  void clear() => songs.clear();

  Song getSong(int index) {
    if (index < 0 || index >= songs.length)
      return null;
    return songs[index];
  }

  void save() async {
    if (_savePath == null) return;
    try {
      await Storage.saveAppFile(_savePath,
          jsonEncode(this.toJson()));
    } catch (e) {}
  }

  void load() async {
    if (_savePath == null) return;
    String json = await Storage.loadAppFile(_savePath);
    if (json == "") return;
    try {
      this.songs = SongsStorage
          .fromJson(jsonDecode(json))
          .songs;
    } catch (e) {

    }
    if (this.songs == null)
      this.songs =   List<Song>();
  }

  Future<bool> deleteSongFile(Song song) async {
    if (song.picpath == null || song.picpath.length == 0)
      return false;
    if(MiniPlayer.instance.url == song.picpath)
      return false;
    await Storage.deleteFile(song.picpath);
    this.songs.remove(song);
    return true;
  }
}