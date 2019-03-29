import 'package:json_annotation/json_annotation.dart';
import 'package:dl_music/storage/storage.dart';
import 'dart:convert';
import 'package:dl_music/api/player.dart';
import 'dart:math';
import 'package:dl_music/storage/storage.song.dart';
import 'package:dl_music/structs/song.dart';
part 'package:dl_music/structs/song.sheet.g.dart';

@JsonSerializable()
class SongSheet extends ISongProvider {
  String _curPlayerSong = "";
  void seekSong(SongInfo song) {
    int idx = songs.indexWhere((dlid) => dlid == song.uniqueName);
    if (idx >= 0)
      _curPlayerSong =  song.uniqueName;
  }

  void inValidSong(SongInfo song)  {
    songs.remove(song.uniqueName);
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
          idx = songs.indexWhere((dlid) => dlid == _curPlayerSong);
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
    Song song = SongStorage.songSave.findSong(songs[idx]);
    if (song == null) {
      songs.removeAt(idx);
      return getNextSong(mode, next);
    }
    _curPlayerSong = song.dlid;
    return SongInfo(songURL: song.picpath,
        songName: song.name,
        uniqueName: song.dlid,
        isLocal: true);
  }

  String name;
  List<String> songs;
  SongSheet({this.name, this.songs});
  factory SongSheet.fromJson(Map<String, dynamic> json) => _$SongSheetFromJson(json);
  Map<String, dynamic> toJson() => _$SongSheetToJson(this);

  void addSong(String song) => songs.insert(0, song);

  get songsNum => songs.length;

  bool remove(String dlid) {
    return songs.remove(dlid);
  }


  bool songExist(String dlid) {
    return songs.indexWhere((s) {
      return s == dlid;
    }) >= 0;
  }

  String getSong(int index) {
    if (index < 0 || index >= songs.length)
      return null;
    return songs[index];
  }

  void save(String file) async {
    try {
      await Storage.saveAppFile(file,
          jsonEncode(this.toJson()));
    } catch (e) {}
  }

  void load(String file) async {
    String json = await Storage.loadAppFile(file);
    if (json == "") return;
    try {
      this.songs = SongSheet
          .fromJson(jsonDecode(json))
          .songs;
    } catch (e) {

    }
    if (this.songs == null)
      this.songs =   List<String>();
  }
}