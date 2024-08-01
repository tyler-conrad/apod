import 'package:flutter_test/flutter_test.dart' as ft;

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart'
    as pppi;
import 'package:hive/hive.dart' as h;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:apod/src/tz/timezone_stub.dart'
    if (dart.library.io) 'package:apod/src/tz/timezone_flutter.dart'
    if (dart.library.js) 'package:apod/src/tz/timezone_web.dart' as timezone;
import 'package:apod/src/database.dart' as d;
import 'package:apod/src/media_metadata.dart' as mm;
import 'package:apod/src/shared.dart' as s;

import 'src/path_provider_platform_fake.dart' as pppf;

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

  pppi.PathProviderPlatform.instance = pppf.FakePathProviderPlatform();

  await h.Hive.initFlutter();

  ft.setUp(() async {
    db = d.Database(
        defaultKeys: defaultKeys,
        box: await h.Hive.openBox<mm.MediaMetadata>(
            defaultKeys.mediaMetadataBoxName));
  });

  ft.tearDown(() async {
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

  ft.group('Database', () {
    ft.test('containsKey() returns false when the key is not present', () {
      ft.expect(db!.containsKey(key: 'missing'), ft.isFalse);
    });

    ft.test('containsKey() returns true when the key is present', () async {
      db!.put(
          metadata: mm.MediaMetadata(
              title: 'title',
              dateTime: DateTime(2021, 1, 1),
              copyright: 'copyright',
              explanation: 'explanation',
              url: 'url',
              hdUrl: 'hdUrl',
              mediaType: mm.MediaType.image));
      ft.expect(db!.containsKey(key: '2021-01-01'), ft.isTrue);
    });

    ft.test(
        'latestMediaMetadataDateTime() throws LatestMediaMetadataNotSetException when it is missing',
        () async {
      ft.expect(() async {
        await db!.latestMediaMetadataDateTime();
      }, ft.throwsA(ft.isA<d.LatestMediaMetadataNotSetException>()));
    });

    ft.test(
        'latestMediaMetadataDateTime() returns the latest date when it is present',
        () async {
      var latest = tz.TZDateTime(s.timeZone, 2021, 1, 1);
      await db!.putLatestMediaMetadataDateTime(latest: latest);
      ft.expect(await db!.latestMediaMetadataDateTime(), ft.equals(latest));
    });

    ft.test(
        'fromDateTime() throws an NoDatabaseKeyException when the DateTime key is not present',
        () {
      ft.expect(
          () =>
              db!.fromDateTime(dateTime: tz.TZDateTime(s.timeZone, 2021, 1, 1)),
          ft.throwsA(ft.isA<d.NoDatabaseKeyException>()));
    });

    ft.test(
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

      ft.expect(metadata.title, ft.equals('title'));
      ft.expect(metadata.dateTime, ft.equals(dt));
      ft.expect(metadata.copyright, ft.equals('copyright'));
      ft.expect(metadata.explanation, ft.equals('explanation'));
      ft.expect(metadata.url, ft.equals('url'));
      ft.expect(metadata.hdUrl, 'hdUrl');
      ft.expect(metadata.mediaType, mm.MediaType.image);
    });

    ft.test('close() closes the MediaMetadata box', () async {
      await db!.close();
      ft.expect(db!.box.isOpen, ft.isFalse);
    });
  });
}
