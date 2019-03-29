import 'package:json_annotation/json_annotation.dart';
part 'package:dl_music/structs/downloadresult.g.dart';
@JsonSerializable()
class DownloadResult {
  int errorcode;
  String url;
  String pvd;
  String dlid;
  bool cache;
  DownloadResult({this.errorcode,this.url, this.pvd, this.dlid, this.cache});
  factory DownloadResult.fromJson(Map<String, dynamic> json) => _$DownloadResultFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadResultToJson(this);
}