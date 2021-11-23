import 'package:hive/hive.dart' as h;
import 'package:timezone/timezone.dart' as tz;

import 'shared.dart' as s;

@h.HiveType(typeId: 1)
enum MediaType {
  @h.HiveField(0)
  image,
  @h.HiveField(1)
  video,
}

class MediaTypeAdapter extends h.TypeAdapter<MediaType> {
  @override
  final int typeId = 1;

  @override
  MediaType read(h.BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MediaType.image;
      case 1:
        return MediaType.video;
      default:
        return MediaType.image;
    }
  }

  @override
  void write(h.BinaryWriter writer, MediaType obj) {
    switch (obj) {
      case MediaType.image:
        writer.writeByte(0);
        break;
      case MediaType.video:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

@h.HiveType(typeId: 0)
class MediaMetadata {
  @h.HiveField(0)
  final String title;
  @h.HiveField(1)
  final DateTime dateTime;
  @h.HiveField(2)
  final String? copyright;
  @h.HiveField(3)
  final String explanation;
  @h.HiveField(4)
  final String? url;
  @h.HiveField(5)
  final String? hdUrl;
  @h.HiveField(6)
  final MediaType mediaType;

  String get copyrightWithSymbol {
    if (copyright == null) {
      return '';
    }
    return '\u00A9$copyright';
  }

  tz.TZDateTime get date {
    return tz.TZDateTime.from(dateTime, s.timeZone);
  }

  factory MediaMetadata.fromJson(Map<String, dynamic> metadata) {
    var dateTime = s.parseDate(dateString: metadata['date']);
    return MediaMetadata(
        title: metadata['title'].split('\n')[0].trim(),
        dateTime: DateTime(dateTime.year, dateTime.month, dateTime.day),
        copyright: metadata['copyright'],
        explanation: metadata['explanation'],
        url: metadata['url'],
        hdUrl: metadata['hdurl'],
        mediaType: metadata['media_type'] == 'image'
            ? MediaType.image
            : MediaType.video);
  }

  MediaMetadata(
      {required this.title,
      required this.dateTime,
      required this.copyright,
      required this.explanation,
      required this.url,
      required this.hdUrl,
      required this.mediaType});
}

class MediaMetadataAdapter extends h.TypeAdapter<MediaMetadata> {
  @override
  final int typeId = 0;

  @override
  MediaMetadata read(h.BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaMetadata(
      title: fields[0] as String,
      dateTime: fields[1] as DateTime,
      copyright: fields[2] as String?,
      explanation: fields[3] as String,
      url: fields[4] as String?,
      hdUrl: fields[5] as String?,
      mediaType: fields[6] as MediaType,
    );
  }

  @override
  void write(h.BinaryWriter writer, MediaMetadata obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.copyright)
      ..writeByte(3)
      ..write(obj.explanation)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.hdUrl)
      ..writeByte(6)
      ..write(obj.mediaType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
