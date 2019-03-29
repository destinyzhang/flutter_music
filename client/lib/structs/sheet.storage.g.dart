// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet.storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetStorage _$SheetStorageFromJson(Map<String, dynamic> json) {
  return SheetStorage(
      sheets: (json['sheets'] as List)
          ?.map((e) =>
              e == null ? null : SongSheet.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$SheetStorageToJson(SheetStorage instance) =>
    <String, dynamic>{'sheets': instance.sheets};
