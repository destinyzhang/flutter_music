// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) {
  return Song(
      singer: json['singer'] as String,
      size: (json['size'] as num)?.toDouble(),
      name: json['name'] as String,
      dlid: json['dlid'] as String,
      interval: (json['interval'] as num)?.toDouble(),
      ablumname: json['ablumname'] as String,
      picpath: json['picpath'] as String);
}

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'singer': instance.singer,
      'size': instance.size,
      'name': instance.name,
      'dlid': instance.dlid,
      'interval': instance.interval,
      'ablumname': instance.ablumname,
      'picpath': instance.picpath
    };
