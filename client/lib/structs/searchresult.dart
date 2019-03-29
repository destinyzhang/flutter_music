import 'package:json_annotation/json_annotation.dart';
import 'package:dl_music/structs/song.dart';
part 'package:dl_music/structs/searchresult.g.dart';
@JsonSerializable()
class SearchResult {
  int errorcode;
  List<Song> songs;
  String key;
  int page;
  bool more;
  String pvd;
  bool cache;
  SearchResult({this.errorcode, this.songs, this.key, this.page, this.more, this.pvd, this.cache});
  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}