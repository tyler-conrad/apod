import 'dart:math' as math;

import 'package:timezone/timezone.dart' as tz;

import 'shared.dart' as s;
import 'client.dart' as ac;
import 'database.dart' as db;
import 'log.dart' as log;
import 'media_metadata.dart' as mm;
import 'media_metadata_by_month.dart' as mmbm;

/// Current state of the database.
enum DatabasePopulationStrategy { populated, needsUpdate, needsInitialLoad }

/// Earliest date the database has media metadata for.
final tz.TZDateTime earliestMediaMetadata =
    tz.TZDateTime(s.timeZone, 1995, 6, 16);

/// Controller for media metadata.
class MediaMetadataController {
  final math.Random _rng;
  final ac.Client _client;
  final db.Database _database;

  /// Constructor for the media metadata controller.
  ///
  /// The media metadata controller requires a [rng], a [client], and a
  /// [database].
  MediaMetadataController({
    required math.Random rng,
    required ac.Client client,
    required db.Database database,
  })  : _database = database,
        _client = client,
        _rng = rng {
    _client.addMediaMetadataOnDateChange(database: _database);
  }

  /// Generate media metadata by month.
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

  /// Check if the media metadata has a valid image.
  bool isValidImage({required mm.MediaMetadata mediaMetadata}) {
    return mediaMetadata.mediaType != mm.MediaType.video &&
        mediaMetadata.url != null &&
        mediaMetadata.hdUrl != null;
  }

  /// Generate media metadata from the latest date to the earliest date.
  Iterable<mm.MediaMetadata> fromLatestBackward() {
    return _backward().where(
      (mediaMetadata) => isValidImage(mediaMetadata: mediaMetadata),
    );
  }

  /// Generate media metadata from the earliest date to the latest date.
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
        yield _database.fromDateTime(dateTime: dateTime);
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
        yield _database.fromDateTime(dateTime: dateTime);
      } on db.NoDatabaseKeyException {
        continue;
      }
    }
  }

  Iterable<mm.MediaMetadata> _random() sync* {
    var daysWithData = s.timeZoneNow().difference(earliestMediaMetadata).inDays;

    while (true) {
      yield _database.fromDateTime(
          dateTime: earliestMediaMetadata
              .add(Duration(days: _rng.nextInt(daysWithData))));
    }
  }

  /// Return a random image url.
  Iterable<mm.MediaMetadata> randomImage() {
    return _random().where((metadata) =>
        metadata.mediaType == mm.MediaType.image && metadata.hdUrl != null);
  }

  /// Return metadata for a specific date.
  mm.MediaMetadata fromDateTime({required tz.TZDateTime dateTime}) {
    return _database.fromDateTime(dateTime: dateTime);
  }

  /// Return the latest media metadata.
  Future<tz.TZDateTime> latestMediaMetadata() async {
    try {
      return (await _database.latestMediaMetadataDateTime());
    } on db.LatestMediaMetadataNotSetException {
      return earliestMediaMetadata;
    }
  }

  /// Return the current state of the database.
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

  /// Update the database based on the current date.
  ///
  /// This method is called when the database needs to be updated.
  Stream<double> updateDatabase() async* {
    tz.TZDateTime now = s.timeZoneNow();
    while (!_database.containsKey(
        key: s.yearMonthDayStringFromDateTime(dateTime: now))) {
      now = now.subtract(const Duration(days: 1));
    }
    await _database.putLatestMediaMetadataDateTime(
        latest: now.add(const Duration(days: 1)));
    yield* populateDatabase();
  }

  /// Populate the database with media metadata.
  Stream<double> populateDatabase() async* {
    var latest = await latestMediaMetadata();
    mm.MediaMetadata? current;
    var mediaMetadataAfterDate =
        _client.allMediaMetadataAfterDate(date: latest);
    var numRequests = mediaMetadataAfterDate.numMediaMetadata;
    var index = 0.0;
    try {
      await for (final metadata in mediaMetadataAfterDate.stream) {
        current = metadata;
        await _database.put(metadata: current);
        index += 1.0;
        yield index / numRequests;
      }
    } catch (e) {
      log.logger.e(
          'Error populating database in MediaMetadataController.build(): $e');
      rethrow;
    }

    await _database.putLatestMediaMetadataDateTime(
        latest: current?.date ?? latest);
  }

  /// Close the database.
  Future<void> close() async {
    await _database.close();
  }

  /// Build the media metadata controller.
  static Future<MediaMetadataController> build() async {
    var database = await db.Database.build();
    return MediaMetadataController(
        rng: math.Random(), client: ac.Client.build(), database: database);
  }
}

late final MediaMetadataController controller;

Future<void> buildController() async {
  controller = await MediaMetadataController.build();
}
