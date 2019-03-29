import 'package:dl_music/structs/songs.storage.dart';
import 'package:dl_music/structs/sheet.storage.dart';

class SongStorage {
  static SongsStorage _songSave = SongsStorage.fromSavePath("songs_list.json");
  static SongsStorage _songDownload = SongsStorage.fromSavePath(
      "download_list.json");
  static SheetStorage _sheetSave = SheetStorage.fromSavePath(
      "sheets_list.json");

  static SongsStorage get songSave => _songSave;

  static SongsStorage get songDownload => _songDownload;

  static SheetStorage get sheetSave => _sheetSave;

  static void init() {
    _songSave.load();
    _songDownload.load();
    _sheetSave.load();
  }
}