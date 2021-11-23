import 'package:hive/hive.dart' as h;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import 'media_metadata.dart' as mm;
import 'shared.dart' as s;

@h.HiveType(typeId: 2)
class LatestMediaMetadata {
  @h.HiveField(0)
  late final DateTime dateTime;

  tz.TZDateTime get latest {
    return tz.TZDateTime(
        s.timeZone, dateTime.year, dateTime.month, dateTime.day);
  }

  set latest(tz.TZDateTime latestDateTime) {
    dateTime =
        DateTime(latestDateTime.year, latestDateTime.month, latestDateTime.day);
  }

  LatestMediaMetadata({required tz.TZDateTime latestDateTime}) {
    latest = latestDateTime;
  }
}

class LatestMediaMetadataAdapter extends TypeAdapter<LatestMediaMetadata> {
  @override
  final int typeId = 2;

  @override
  LatestMediaMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LatestMediaMetadata(
        latestDateTime: tz.TZDateTime.from(fields[0] as DateTime, s.timeZone));
  }

  @override
  void write(BinaryWriter writer, LatestMediaMetadata obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatestMediaMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DefaultKeys {
  final String latestMediaMetadataBoxName;
  final String latestMediaMetadataKeyName;
  final String mediaMetadataBoxName;

  static DefaultKeys build() {
    return DefaultKeys(
        latestMediaMetadataBoxName: 'latest_media_metadata_box_name',
        latestMediaMetadataKeyName: 'latest_media_metadata_key_name',
        mediaMetadataBoxName: 'media_metadata_box_name');
  }

  DefaultKeys(
      {required this.latestMediaMetadataBoxName,
      required this.latestMediaMetadataKeyName,
      required this.mediaMetadataBoxName});
}

class NoDatabaseKeyException implements Exception {
  final String msg;
  const NoDatabaseKeyException(this.msg);
}

class LatestMediaMetadataNotSetException implements Exception {
  final String msg;
  const LatestMediaMetadataNotSetException(this.msg);
}

class Database {
  final DefaultKeys defaultKeys;
  final h.Box<mm.MediaMetadata> box;

  bool containsKey({required String key}) {
    return box.containsKey(key);
  }

  Future<tz.TZDateTime> latestMediaMetadataDateTime() async {
    final latestBox = await h.Hive.openBox<LatestMediaMetadata>(
        defaultKeys.latestMediaMetadataBoxName);
    var latestMediaMetadata =
        latestBox.get(defaultKeys.latestMediaMetadataKeyName);
    if (latestMediaMetadata == null) {
      await latestBox.close();
      throw LatestMediaMetadataNotSetException(
          '${defaultKeys.latestMediaMetadataKeyName} key does not exist');
    }
    await latestBox.close();
    return latestMediaMetadata.latest;
  }

  Future<Database> putLatestMediaMetadataDateTime(
      {required tz.TZDateTime latest}) async {
    var latestBox =
        await h.Hive.openBox(defaultKeys.latestMediaMetadataBoxName);
    await latestBox.put(defaultKeys.latestMediaMetadataKeyName,
        LatestMediaMetadata(latestDateTime: latest));
    await latestBox.close();
    return this;
  }

  mm.MediaMetadata fromDateTime({required tz.TZDateTime dateTime}) {
    var dateString = s.yearMonthDayStringFromDateTime(dateTime: dateTime);
    if (!containsKey(key: dateString)) {
      throw NoDatabaseKeyException(
          'No key in Database for date String: $dateString');
    }
    return box.get(dateString)!;
  }

  Future<Database> put({required mm.MediaMetadata metadata}) async {
    await box.put(
        s.yearMonthDayStringFromDateTime(dateTime: metadata.date), metadata);
    return this;
  }

  Future<void> close() async {
    await box.close();
  }

  static Future<Database> build() async {
    h.Hive.registerAdapter(LatestMediaMetadataAdapter());
    h.Hive.registerAdapter(mm.MediaTypeAdapter());
    h.Hive.registerAdapter(mm.MediaMetadataAdapter());

    await h.Hive.initFlutter();

    var defaultKeys = DefaultKeys.build();

    return Database(
        defaultKeys: defaultKeys,
        box: await h.Hive.openBox<mm.MediaMetadata>(
            defaultKeys.mediaMetadataBoxName));
  }

  Database({required this.defaultKeys, required this.box});
}
