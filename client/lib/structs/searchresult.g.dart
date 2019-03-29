// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchresult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) {
  return SearchResult(
      errorcode: json['errorcode'] as int,
      songs: (json['songs'] as List)
          ?.map((e) =>
              e == null ? null : Song.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      key: json['key'] as String,
      page: json['page'] as int,
      more: json['more'] as bool,
      pvd: json['pvd'] as String,
      cache: json['cache'] as bool);
}

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'errorcode': instance.errorcode,
      'songs': instance.songs,
      'key': instance.key,
      'page': instance.page,
      'more': instance.more,
      'pvd': instance.pvd,
      'cache': instance.cache
    };
