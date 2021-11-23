import 'package:apod/src/tz/timezone_stub.dart'
    if (dart.library.io) 'package:apod/src/tz/timezone_flutter.dart'
    if (dart.library.js) 'package:apod/src/tz/timezone_web.dart' as timezone;

import 'package:test/test.dart' as t;
import 'package:apod/src/client.dart' as c;
import 'package:apod/src/shared.dart' as s;
import 'package:timezone/timezone.dart' as tz;

void main() {
  t.setUp(() async {
    await timezone.setup();
  });

  t.group('datePairIterable()', () {
    t.test(
        'returns an empty Iterable when supplied with an empty List<DateTime> argument',
        () {
      t.expect(c.datePairIterable(dateTimes: []).toList(), t.equals([]));
    });

    t.test(
        'returns a pair of equal DateTimes when passed a list with a single element',
        () {
      t.expect(
          c.datePairIterable(dateTimes: [
            tz.TZDateTime(s.timeZone, 2021, 1, 1)
          ]).toList(),
          t.equals([
            [
              tz.TZDateTime(s.timeZone, 2021, 1, 1),
              tz.TZDateTime(s.timeZone, 2021, 1, 1)
            ]
          ]));
    });

    t.test(
        'returns all date pairs supplied in a List<DateTime> with the last pair spanning List.length - 3 to List.length - 1',
        () {
      t.expect(
          c.datePairIterable(
                  dateTimes: s.dateIterable(
                          startDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
                          endDate: tz.TZDateTime(s.timeZone, 2021, 1, 7),
                          offset: 2)
                      .toList())
              .toList(),
          t.equals([
            [tz.TZDateTime(s.timeZone, 2021, 1, 1), tz.TZDateTime(s.timeZone, 2021, 1, 2)],
            [tz.TZDateTime(s.timeZone, 2021, 1, 3), tz.TZDateTime(s.timeZone, 2021, 1, 4)],
            [tz.TZDateTime(s.timeZone, 2021, 1, 5), tz.TZDateTime(s.timeZone, 2021, 1, 7)],
          ]));
    });
  });

  t.group('NowAndFutureDay', () {
    t.test(
        'the calculated future day is one minute past the beginning of the future day',
        () {
      var nafd = c.NowAndFutureDay(dayOffset: 1);
      var futureDay = nafd.now.add(const Duration(days: 1));
      var truncatedFutureDay = tz.TZDateTime(s.timeZone,
          futureDay.year, futureDay.month, futureDay.day, 0, 1);
      t.expect(nafd.futureDay, t.equals(truncatedFutureDay));
    });

    t.test(
        'the calculated future day is one minute past the beginning of the future day for dayOffsets greater than 1',
        () {
      var nafd = c.NowAndFutureDay(dayOffset: 5);
      var futureDay = nafd.now.add(const Duration(days: 5));
      var truncatedFutureDay = tz.TZDateTime(s.timeZone,
          futureDay.year, futureDay.month, futureDay.day, 0, 1);
      t.expect(nafd.futureDay, t.equals(truncatedFutureDay));
    });
  });

  t.group('throttledRequestIterable()', () {
    t.test('it returns a single Uri when iterating over the last two days', () {
      var now = s.timeZoneNow();
      var iterator = c.Client.build()
          .uriIterable(
              startDate: now.subtract(const Duration(days: 2)))
          .iterator;
      iterator.moveNext();
      Uri uri = iterator.current;
      t.expect(uri.path, t.equals('/v1/apod'));
      t.expect(
          {...uri.queryParameters.keys},
          t.equals(
              {'thumbs', 'start_date', 'end_date'}));
      t.expect(
          uri.queryParameters['start_date'],
          t.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 2)))));
      t.expect(
          uri.queryParameters['end_date'],
          t.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 0)))));
      t.expect(iterator.moveNext(), t.equals(false));
    });

    t.test(
        'it returns two Uris when iterating over the a date range with more days that Client.numMediaMetadataPerCall',
        () {
      var now = s.timeZoneNow();
      var iterator = c.Client.build()
          .uriIterable(
              startDate: now.subtract(const Duration(
                  days: c.Client.numMediaMetadataPerCall + 2)))
          .iterator;
      iterator.moveNext();
      var uri = iterator.current;
      t.expect(uri.path, t.equals('/v1/apod'));
      t.expect(
          {...uri.queryParameters.keys},
          t.equals(
              {'thumbs', 'start_date', 'end_date'}));
      t.expect(
          uri.queryParameters['start_date'],
          t.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(
                  days: c.Client.numMediaMetadataPerCall + 2)))));
      t.expect(
          uri.queryParameters['end_date'],
          t.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 3)))));
      t.expect(iterator.moveNext(), t.equals(true));
      uri = iterator.current;
      t.expect(
          uri.queryParameters['start_date'],
          t.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 2)))));
      t.expect(
          uri.queryParameters['end_date'],
          t.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 0)))));
      t.expect(iterator.moveNext(), t.equals(false));
    });
  });
}
