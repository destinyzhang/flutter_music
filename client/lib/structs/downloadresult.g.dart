// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloadresult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadResult _$DownloadResultFromJson(Map<String, dynamic> json) {
  return DownloadResult(
      errorcode: json['errorcode'] as int,
      url: json['url'] as String,
      pvd: json['pvd'] as String,
      dlid: json['dlid'] as String,
      cache: json['cache'] as bool);
}

Map<String, dynamic> _$DownloadResultToJson(DownloadResult instance) =>
    <String, dynamic>{
      'errorcode': instance.errorcode,
      'url': instance.url,
      'pvd': instance.pvd,
      'dlid': instance.dlid,
      'cache': instance.cache
    };
