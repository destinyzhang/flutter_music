import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dl_music/storage/storage.song.dart';
class Storage {
  static String _appPath = "";
  static String _tempPath = "";
  static get appPath => _appPath;
  static get tempPath => _tempPath;
  static Future<bool> _checkFileExist(File file) async {
    try {
      return await file.exists();
    } catch (e) {
      print("_checkFileExist catch exception :${e.toString()}");
      return false;
    }
  }

  static Future<bool> _saveFile(File file,String content) async {
    try {
      await file.writeAsString(content);
      return await file.exists();
    } catch (e) {
      print("_saveFile catch exception :${e.toString()}");
      return false;
    }
  }

  static Future<bool> _saveByteFile(File file,List<int> bytes) async {
    try {
      await file.writeAsBytes(bytes);
      return await file.exists();
    } catch (e) {
      print("_saveByteFile catch exception :${e.toString()}");
      return false;
    }
  }
  static Future<bool> _deleteFile(File file) async {
    try {
      var fileSys = await file.delete();
      return !await fileSys.exists();
    } catch (e) {
      print("_saveFile catch exception :${e.toString()}");
      return false;
    }
  }

  static Future<bool> deleteFile(String fileName) async {
    return await _deleteFile(File("$fileName"));
  }


  static Future<bool> deleteAppFile(String fileName) async {
    return await _deleteFile(File("$_appPath\/$fileName"));
  }

  static Future<bool> deleteTempFile(String fileName) async {
    return await _deleteFile(File("$_tempPath\/$fileName"));
  }

  static Future<bool> checkFileExist(String fileName) async {
    return await _checkFileExist(File("$fileName"));
  }

  static Future<bool> checkAppFileExist(String fileName) async {
    return await _checkFileExist(File("$_appPath\/$fileName"));
  }

  static Future<bool> checkTempFileExist(String fileName) async {
    return await _checkFileExist(File("$_tempPath\/$fileName"));
  }

  static Future<bool> saveTempByteFile(String fileName, List<int> bytes) async {
    return await _saveByteFile(File("$_tempPath\/$fileName"),bytes);
  }

  static Future<bool> saveAppByteFile(String fileName, List<int> bytes) async {
    return await _saveByteFile(File("$_appPath\/$fileName"), bytes);
  }

  static Future<bool> saveTempFile(String fileName, String content) async {
    return await _saveFile(File("$_tempPath\/$fileName"),content);
  }

  static Future<bool> saveAppFile(String fileName, String content) async {
    return await _saveFile(File("$_appPath\/$fileName"),content);
  }

  static Future<String> _loadFile(File file) async {
    bool isExist = await file.exists();
    if (isExist) {
      try {
        return await file.readAsString();
      } catch (e) {
        print("_loadFile catch exception :${e.toString()}");
      }
    }
    return "";
  }

  static Future<String> loadTempFile(String fileName) async {
    return await _loadFile(File("$_tempPath\/$fileName"));
  }

  static Future<String> loadAppFile(String fileName) async {
    return await _loadFile(File("$_appPath\/$fileName"));
  }

  static Future<void> _initPath() async {
    _appPath = (await getApplicationDocumentsDirectory()).path;
    _tempPath = (await getTemporaryDirectory()).path;
  }

  static void init() async {
    await _initPath();
    SongStorage.init();
  }
}