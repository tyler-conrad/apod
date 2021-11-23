import 'package:test/test.dart' as t;
import 'package:hive/hive.dart' as h;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:apod/src/tz/timezone_stub.dart'
    if (dart.library.io) 'package:apod/src/tz/timezone_flutter.dart'
    if (dart.library.js) 'package:apod/src/tz/timezone_web.dart' as timezone;

import 'package:apod/src/database.dart' as d;
import 'package:apod/src/media_metadata.dart' as mm;
import 'package:apod/src/shared.dart' as s;

void main() async {
  await timezone.setup();

  d.Database? db;

  h.Hive.registerAdapter(d.LatestMediaMetadataAdapter());
  h.Hive.registerAdapter(mm.MediaTypeAdapter());
  h.Hive.registerAdapter(mm.MediaMetadataAdapter());

  var defaultKeys = d.DefaultKeys(
      latestMediaMetadataBoxName: 'latestMediaMetadataBoxName',
      latestMediaMetadataKeyName: 'latestMediaMetadataKeyName',
      mediaMetadataBoxName: 'mediaMetadataBoxName');

  await h.Hive.initFlutter();

  t.setUp(() async {
    db = d.Database(
        defaultKeys: defaultKeys,
        box: await h.Hive.openBox<mm.MediaMetadata>(
            defaultKeys.mediaMetadataBoxName));
  });

  t.tearDown(() async {
    if (db!.box.isOpen) {
      await db!.box.clear();
      await db!.box.close();
    } else {
      var mmBox = await h.Hive.openBox(defaultKeys.mediaMetadataBoxName);
      await mmBox.clear();
      await mmBox.close();
    }
    var lmmBox = await h.Hive.openBox(defaultKeys.latestMediaMetadataBoxName);
    await lmmBox.clear();
    await lmmBox.close();
  });

  t.group('Database', () {
    t.test('containsKey() returns false when the key is not present', () {
      t.expect(db!.containsKey(key: 'missing'), t.isFalse);
    });

    t.test('containsKey() returns true when the key is present', () async {
      db!.put(
          metadata: mm.MediaMetadata(
              title: 'title',
              dateTime: DateTime(2021, 1, 1),
              copyright: 'copyright',
              explanation: 'explanation',
              url: 'url',
              hdUrl: 'hdUrl',
              mediaType: mm.MediaType.image));
      t.expect(db!.containsKey(key: '2021-01-01'), t.isTrue);
    });

    t.test(
        'latestMediaMetadataDateTime() throws LatestMediaMetadataNotSetException when it is missing',
        () async {
      t.expect(() async {
        await db!.latestMediaMetadataDateTime();
      }, t.throwsA(t.isA<d.LatestMediaMetadataNotSetException>()));
    });

    t.test(
        'latestMediaMetadataDateTime() returns the latest date when it is present',
        () async {
      var latest = tz.TZDateTime(s.timeZone, 2021, 1, 1);
      await db!.putLatestMediaMetadataDateTime(latest: latest);
      t.expect(await db!.latestMediaMetadataDateTime(), t.equals(latest));
    });

    t.test(
        'fromDateTime() throws an NoDatabaseKeyException when the DateTime key is not present',
        () {
      t.expect(
          () =>
              db!.fromDateTime(dateTime: tz.TZDateTime(s.timeZone, 2021, 1, 1)),
          t.throwsA(t.isA<d.NoDatabaseKeyException>()));
    });

    t.test(
        'fromDateTime() returns a MediaMetadata value when the DateTime key is present',
        () async {
      var dt = DateTime(2021, 1, 1);

      db!.put(
          metadata: mm.MediaMetadata(
              title: 'title',
              dateTime: dt,
              copyright: 'copyright',
              explanation: 'explanation',
              url: 'url',
              hdUrl: 'hdUrl',
              mediaType: mm.MediaType.image));

      var metadata = db!.fromDateTime(
          dateTime: tz.TZDateTime(s.timeZone, dt.year, dt.month, dt.day));

      t.expect(metadata.title, t.equals('title'));
      t.expect(metadata.dateTime, t.equals(dt));
      t.expect(metadata.copyright, t.equals('copyright'));
      t.expect(metadata.explanation, t.equals('explanation'));
      t.expect(metadata.url, t.equals('url'));
      t.expect(metadata.hdUrl, 'hdUrl');
      t.expect(metadata.mediaType, mm.MediaType.image);
    });

    t.test('close() closes the MediaMetadata box', () async {
      await db!.close();
      t.expect(db!.box.isOpen, t.isFalse);
    });
  });
}
