import 'dart:math' as math;

import 'package:timezone/timezone.dart' as tz;

import 'shared.dart' as s;
import 'client.dart' as ac;
import 'database.dart' as db;
import 'log.dart' as log;
import 'media_metadata.dart' as mm;
import 'media_metadata_by_month.dart' as mmbm;

enum DatabasePopulationStrategy { populated, needsUpdate, needsInitialLoad }

final tz.TZDateTime earliestMediaMetadata =
    tz.TZDateTime(s.timeZone, 1995, 6, 16);

class MediaMetadataController {
  final math.Random rng;
  final ac.Client client;
  final db.Database database;

  Iterable<mmbm.MediaMetadataByMonth> mediaMetadataByMonth(
      {required Iterable<mm.MediaMetadata> mediaMetadataIterable}) sync* {
    final iterator = mediaMetadataIterable.iterator;
    var iterating = iterator.moveNext();
    while (iterating) {
      final currentMonthAndYear =
          mmbm.MonthAndYear(dateTime: iterator.current.date);
      var nextMonthAndYear = mmbm.MonthAndYear(dateTime: iterator.current.date);
      final List<mm.MediaMetadata> mediaMetadataList = [];
      while (currentMonthAndYear == nextMonthAndYear) {
        mediaMetadataList.add(iterator.current);
        iterating = iterator.moveNext();
        if (!iterating) {
          break;
        }
        nextMonthAndYear = mmbm.MonthAndYear(dateTime: iterator.current.date);
      }
      yield mmbm.MediaMetadataByMonth(
          monthAndYear: currentMonthAndYear,
          mediaMetadataForMonth: mediaMetadataList);
    }
  }

  bool isValidImage({required mm.MediaMetadata mediaMetadata}) {
    return mediaMetadata.mediaType != mm.MediaType.video &&
        mediaMetadata.url != null &&
        mediaMetadata.hdUrl != null;
  }

  Iterable<mm.MediaMetadata> fromLatestBackward() {
    return _backward().where(
      (mediaMetadata) => isValidImage(mediaMetadata: mediaMetadata),
    );
  }

  Iterable<mm.MediaMetadata> fromEarliestForward() {
    return _forward().where(
      (mediaMetadata) => isValidImage(mediaMetadata: mediaMetadata),
    );
  }

  Iterable<mm.MediaMetadata> _backward() sync* {
    for (final dateTime in s
        .dateIterable(
          startDate: earliestMediaMetadata,
          endDate: s.timeZoneNow(),
          offset: 1,
        )
        .toList()
        .reversed) {
      try {
        yield database.fromDateTime(dateTime: dateTime);
      } on db.NoDatabaseKeyException {
        continue;
      }
    }
  }

  Iterable<mm.MediaMetadata> _forward() sync* {
    for (final dateTime in s.dateIterable(
      startDate: earliestMediaMetadata,
      endDate: s.timeZoneNow(),
      offset: 1,
    )) {
      try {
        yield database.fromDateTime(dateTime: dateTime);
      } on db.NoDatabaseKeyException {
        continue;
      }
    }
  }

  Iterable<mm.MediaMetadata> _random() sync* {
    var daysWithData = s.timeZoneNow().difference(earliestMediaMetadata).inDays;

    while (true) {
      yield database.fromDateTime(
          dateTime: earliestMediaMetadata
              .add(Duration(days: rng.nextInt(daysWithData))));
    }
  }

  Iterable<mm.MediaMetadata> randomImage() {
    return _random().where((metadata) =>
        metadata.mediaType == mm.MediaType.image && metadata.hdUrl != null);
  }

  mm.MediaMetadata fromDateTime({required tz.TZDateTime dateTime}) {
    return database.fromDateTime(dateTime: dateTime);
  }

  Future<tz.TZDateTime> latestMediaMetadata() async {
    try {
      return (await database.latestMediaMetadataDateTime());
    } on db.LatestMediaMetadataNotSetException {
      return earliestMediaMetadata;
    }
  }

  Future<DatabasePopulationStrategy> databasePopulationStrategy() async {
    var latest = await latestMediaMetadata();

    if (latest == earliestMediaMetadata) {
      return DatabasePopulationStrategy.needsInitialLoad;
    }

    var nowEastern = s.timeZoneNow();
    if (latest ==
        tz.TZDateTime(
            s.timeZone, nowEastern.year, nowEastern.month, nowEastern.day)) {
      return DatabasePopulationStrategy.populated;
    }
    return DatabasePopulationStrategy.needsUpdate;
  }

  Stream<double> updateDatabase() async* {
    tz.TZDateTime now = s.timeZoneNow();
    while (!database.containsKey(
        key: s.yearMonthDayStringFromDateTime(dateTime: now))) {
      now = now.subtract(const Duration(days: 1));
    }
    await database.putLatestMediaMetadataDateTime(
        latest: now.add(const Duration(days: 1)));
    yield* populateDatabase();
  }

  Stream<double> populateDatabase() async* {
    var latest = await latestMediaMetadata();
    mm.MediaMetadata? current;
    var mediaMetadataAfterDate = client.allMediaMetadataAfterDate(date: latest);
    var numRequests = mediaMetadataAfterDate.numMediaMetadata;
    var index = 0.0;
    try {
      await for (final metadata in mediaMetadataAfterDate.stream) {
        current = metadata;
        await database.put(metadata: current);
        index += 1.0;
        yield index / numRequests;
      }
    } catch (e) {
      log.logger.e(
          'Error populating database in MediaMetadataController.build(): $e');
      rethrow;
    }

    await database.putLatestMediaMetadataDateTime(
        latest: current?.date ?? latest);
  }

  Future<void> close() async {
    await database.close();
  }

  static Future<MediaMetadataController> build() async {
    var database = await db.Database.build();
    return MediaMetadataController(
        rng: math.Random(), client: ac.Client.build(), database: database);
  }

  MediaMetadataController(
      {required this.rng, required this.client, required this.database}) {
    client.addMediaMetadataOnDateChange(database: database);
  }
}

late final MediaMetadataController controller;

Future<void> buildController() async {
  controller = await MediaMetadataController.build();
}
