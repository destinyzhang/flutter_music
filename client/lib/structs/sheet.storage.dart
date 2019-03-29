import 'package:json_annotation/json_annotation.dart';
import 'package:dl_music/structs/song.sheet.dart';
import 'package:dl_music/storage/storage.dart';
import 'dart:convert';
import 'package:dl_music/pages/toast.dart';

part 'package:dl_music/structs/sheet.storage.g.dart';

@JsonSerializable()
class SheetStorage {
  String _savePath;
  List<SongSheet> sheets;

  SheetStorage({this.sheets});

  factory SheetStorage.fromSavePath(String path){
    SheetStorage storage = SheetStorage(sheets:   List<SongSheet>());
    storage._savePath = path;
    return storage;
  }

  factory SheetStorage.fromJson(Map<String, dynamic> json) =>
      _$SheetStorageFromJson(json);

  Map<String, dynamic> toJson() => _$SheetStorageToJson(this);

   bool sheetsHaveSong(String dlid) {
     for (var sheet in sheets) {
       if (sheet.songExist(dlid))
         return true;
     }
     return false;
   }

  bool nameExist(String name) {
    return sheets.indexWhere((sheet) => name == sheet.name) >= 0;
  }

  void removeSheet(String name) {
    sheets.removeWhere((sheet) => sheet.name == name);
    save();
  }

  bool renameSheet(String name,String newName) {
    int index = sheets.indexWhere((sheet) => name == sheet.name);
    if (index < 0)
      return false;
    sheets[index].name = newName;
    save();
    return true;
  }

  void addNewSheet(String name) {
    sheets.add(SongSheet(name: name, songs: List<String>()));
    save();
  }

  SongSheet getSheet(int index) {
    if (index < 0 || index >= sheets.length)
      return null;
    return sheets[index];
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
      this.sheets = SheetStorage
          .fromJson(jsonDecode(json))
          .sheets;
    } catch (e) {}
    if (this.sheets == null)
      this.sheets =   List<SongSheet>();
  }
}