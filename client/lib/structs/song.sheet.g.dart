// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.sheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SongSheet _$SongSheetFromJson(Map<String, dynamic> json) {
  return SongSheet(
      name: json['name'] as String,
      songs: (json['songs'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$SongSheetToJson(SongSheet instance) =>
    <String, dynamic>{'name': instance.name, 'songs': instance.songs};
