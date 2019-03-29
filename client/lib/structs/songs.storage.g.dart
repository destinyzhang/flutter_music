// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs.storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SongsStorage _$SongsStorageFromJson(Map<String, dynamic> json) {
  return SongsStorage(
      songs: (json['songs'] as List)
          ?.map((e) =>
              e == null ? null : Song.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$SongsStorageToJson(SongsStorage instance) =>
    <String, dynamic>{'songs': instance.songs};
