import 'dart:convert' as convert;
import 'dart:async' as async;

import 'package:http/retry.dart' as retry;
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

import 'media_metadata.dart' as mm;
import 'shared.dart' as s;
import 'database.dart' as db;

Map<String, dynamic> _decodeJsonMap({required http.Response resp}) {
  return convert.jsonDecode(convert.utf8.decode(resp.bodyBytes));
}

List<dynamic> _decodeJsonList({required http.Response resp}) {
  return convert.jsonDecode(convert.utf8.decode(resp.bodyBytes));
}

Iterable<List<tz.TZDateTime>> datePairIterable(
    {required List<tz.TZDateTime> dateTimes}) sync* {
  if (dateTimes.isEmpty) {
    return;
  }

  if (dateTimes.length == 1) {
    yield [dateTimes[0], dateTimes[0]];
  }

  tz.TZDateTime curDateTime = dateTimes[0];
  for (var i = 1; i < dateTimes.length; i++) {
    yield [
      curDateTime,
      i == dateTimes.length - 1
          ? dateTimes[i]
          : dateTimes[i].subtract(const Duration(days: 1))
    ];
    curDateTime = dateTimes[i];
  }
}

class NowAndFutureDay {
  final tz.TZDateTime now = s.timeZoneNow();
  late final tz.TZDateTime futureDay;

  tz.TZDateTime futureDayFromOffset({required int dayOffset}) {
    tz.TZDateTime nextDay = now.add(Duration(days: dayOffset));
    return tz.TZDateTime(
        s.timeZone, nextDay.year, nextDay.month, nextDay.day, 0, 1);
  }

  NowAndFutureDay({required int dayOffset}) {
    assert(dayOffset > 0,
        'NowAndFutureDay dayOffset constructor argument must be greater than 0');
    futureDay = futureDayFromOffset(dayOffset: dayOffset);
  }
}

class MediaMetadataAfterDate {
  final Stream<mm.MediaMetadata> stream;
  final int numMediaMetadata;

  MediaMetadataAfterDate(
      {required this.stream, required this.numMediaMetadata});
}

class Client {
  static const int numMediaMetadataPerCall = 100;
  static const scheme = 'http';
  static const host = 'localhost';
  static const port = 8000;
  static const path = '/v1/apod';

  final retry.RetryClient client;

  Iterable<Uri> uriIterable({required tz.TZDateTime startDate}) sync* {
    var uriList = datePairIterable(dateTimes: [
      ...s.dateIterable(
          startDate: startDate,
          endDate: s.timeZoneNow(),
          offset: numMediaMetadataPerCall)
    ]).map((dateTimePair) {
      return Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: path,
        queryParameters: {
          'thumbs': 'True',
          'start_date':
              s.yearMonthDayStringFromDateTime(dateTime: dateTimePair[0]),
          'end_date':
              s.yearMonthDayStringFromDateTime(dateTime: dateTimePair[1])
        },
      );
    }).toList();
    for (final uri in uriList) {
      yield uri;
    }
  }

  Future<void> addMediaMetadataOnDateChange(
      {required db.Database database, int dayOffset = 1}) async {
    NowAndFutureDay nafd = NowAndFutureDay(dayOffset: dayOffset);
    await async.Future.delayed(nafd.futureDay.difference(nafd.now));
    var resp = await client.get(
      Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: path,
        queryParameters: {
          'thumbs': 'True',
          'date': s.yearMonthDayStringFromDateTime(dateTime: nafd.futureDay)
        },
      ),
    );
    var metadata = mm.MediaMetadata.fromJson(_decodeJsonMap(resp: resp));
    await database.put(metadata: metadata);
    await database.putLatestMediaMetadataDateTime(latest: metadata.date);
    await addMediaMetadataOnDateChange(
        database: database, dayOffset: dayOffset + 1);
  }

  Stream<mm.MediaMetadata> _allMediaMetadataAfterDateStream(
      {required tz.TZDateTime date}) async* {
    for (final chunk in s.chunks<Uri>(
      list: uriIterable(startDate: date).toList(),
      chunkSize: 20,
    )) {
      var responses =
          await Future.wait(chunk.map((uri) => client.get(uri)).toList());
      for (final resp in responses) {
        List<dynamic> metadataList;
        try {
          metadataList = _decodeJsonList(resp: resp);
        } on TypeError {
          continue;
        }
        for (final metadata in metadataList) {
          yield mm.MediaMetadata.fromJson(metadata);
        }
      }
    }
  }

  MediaMetadataAfterDate allMediaMetadataAfterDate(
      {required tz.TZDateTime date}) {
    var allMediaMetadataStream = _allMediaMetadataAfterDateStream(date: date);
    return MediaMetadataAfterDate(
      stream: allMediaMetadataStream,
      numMediaMetadata: s.timeZoneNow().difference(date).inDays + 1,
    );
  }

  static Client build() {
    return Client(
        client: retry.RetryClient(http.Client(),
            delay: (_) => const Duration(seconds: 5)));
  }

  Client({required this.client});
}
