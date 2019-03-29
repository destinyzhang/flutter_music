import 'package:json_annotation/json_annotation.dart';
part 'package:dl_music/structs/song.g.dart';

@JsonSerializable()
class Song {
  String singer;
  double size;
  String name;
  String dlid;
  double interval;
  String ablumname;
  String picpath;
  Song({this.singer, this.size, this.name, this.dlid, this.interval, this.ablumname, this.picpath});
  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);

  String getTime() {
    int m = interval ~/ 60;
    var s = (interval.toInt() - 60 * m);
    return "$m:$s";
  }

  String getFileName() {
    return "$dlid.mp3";
  }

  String getSize() {
    return (size / (1024 * 1024)).toStringAsFixed(2) + "MB";
  }
}