import 'package:dl_music/structs/searchresult.dart';
import 'package:dl_music/structs/downloadresult.dart';
import 'package:dl_music/storage/unit.dart';
import 'package:dio/dio.dart';

class ErrCode {
  //ErrCodeSaveFail 保存文件失败
  static const int ErrCodeSaveFail = -3;

  //ErrCodeServer404 服务器未响应
  static const int ErrCodeServer404 = -2;

  //ErrCodeDURLFail 下载失败
  static const int ErrCodeDownloadFail = -1;

  //ErrCodeOk 成功
  static const int ErrCodeOk = 0;

  //ErrCodePvdNil 非法pvd
  static const int ErrCodePvdNil = 1;

  //ErrCodeParmInvalid 参数错误
  static const int ErrCodeParmInvalid = 2;

  //ErrCodeSearchFail 查询失败
  static const int ErrCodeSearchFail = 3;

  //ErrCodeDURLFail 生成下载链接失败
  static const int ErrCodeDURLFail = 4;

  //对应信息
  static const List<String> _remoteErrMsg = [
    "成功", "非法pvd", "参数错误", "查询失败", "生成下载链接失败"];
  static const List<String> _localErrMsg = ["", "下载失败", "服务器未响应", "保存文件失败"];

  static String _errMsg(int code, List<String> msg) {
    if (code < 0 || code >= msg.length)
      return "未知错误";
    return msg[code];
  }

  static String errMsg(int code) {
    if (code < 0)
      return _errMsg(0 - code, _localErrMsg);
    return _errMsg(code, _remoteErrMsg);
  }

}

class MusicApi {
  //static String _baseUrl = "http://192.168.31.162:8080/api/music";
  static String _baseUrl = "http://192.168.1.42:8080/api/music";

 //static String _baseUrl = "http://192.168.199.171:8080/api/music";
  static String _gitAddress = "https://gitee.com/dylove/music_server/raw/master/address";
  static const int _connectTimeout = 20000;
  static const int _receiveTimeout = 20000;

  static String get baseUrl => _baseUrl;

  static Future<void> getSeverUrl(bool init) async {
    if (!Unit.instance.inProduction && init)
      return;
    try {
      Dio dio = Dio(BaseOptions(baseUrl: _baseUrl,
          connectTimeout: _connectTimeout,
          receiveTimeout: _receiveTimeout));
      Response response = await dio.get(_gitAddress);
      if (response.statusCode == 200) {
        _baseUrl = response.data;
      }
    } catch (e) {
      print("catch exception :${e.toString()}");
    }
  }

  static Future<SearchResult> search(String key, int page,
      {String pvd = "qq"}) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: _baseUrl,
          connectTimeout: _connectTimeout,
          receiveTimeout: _receiveTimeout));
      Response response = await dio.get(
          "/search", queryParameters: {"key": key, "page": page, "pvd": pvd});
      if (response.statusCode == 200) {
        return SearchResult.fromJson(response.data);
      }
    } catch (e) {
      print("catch exception :${e.toString()}");
    }
    return null;
  }

  static Future<DownloadResult> getDownloadURL(String dlid,
      {String pvd = "qq"}) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: _baseUrl,
          connectTimeout: _connectTimeout,
          receiveTimeout: _receiveTimeout));
      Response response = await dio.get(
          "/download", queryParameters: {"dlid": dlid, "pvd": pvd});
      if (response.statusCode == 200) {
        return DownloadResult.fromJson(response.data);
      }
    } catch (e) {
      print("catch exception :${e.toString()}");
    }
    return null;
  }
}