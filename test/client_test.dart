import 'package:flutter_test/flutter_test.dart' as ft;

import 'package:apod/src/tz/timezone_stub.dart'
    if (dart.library.io) 'package:apod/src/tz/timezone_flutter.dart'
    if (dart.library.js) 'package:apod/src/tz/timezone_web.dart' as timezone;
import 'package:apod/src/client.dart' as c;
import 'package:apod/src/shared.dart' as s;
import 'package:timezone/timezone.dart' as tz;

void main() {
  ft.setUp(() async {
    await timezone.setup();
  });

  ft.group('datePairIterable()', () {
    ft.test(
        'returns an empty Iterable when supplied with an empty List<DateTime> argument',
        () {
      ft.expect(c.datePairIterable(dateTimes: []).toList(), ft.equals([]));
    });

    ft.test(
        'returns a pair of equal DateTimes when passed a list with a single element',
        () {
      ft.expect(
          c.datePairIterable(
              dateTimes: [tz.TZDateTime(s.timeZone, 2021, 1, 1)]).toList(),
          ft.equals([
            [
              tz.TZDateTime(s.timeZone, 2021, 1, 1),
              tz.TZDateTime(s.timeZone, 2021, 1, 1)
            ]
          ]));
    });

    ft.test(
        'returns all date pairs supplied in a List<DateTime> with the last pair spanning List.length - 3 to List.length - 1',
        () {
      ft.expect(
          c
              .datePairIterable(
                  dateTimes: s
                      .dateIterable(
                          startDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
                          endDate: tz.TZDateTime(s.timeZone, 2021, 1, 7),
                          offset: 2)
                      .toList())
              .toList(),
          ft.equals([
            [
              tz.TZDateTime(s.timeZone, 2021, 1, 1),
              tz.TZDateTime(s.timeZone, 2021, 1, 2)
            ],
            [
              tz.TZDateTime(s.timeZone, 2021, 1, 3),
              tz.TZDateTime(s.timeZone, 2021, 1, 4)
            ],
            [
              tz.TZDateTime(s.timeZone, 2021, 1, 5),
              tz.TZDateTime(s.timeZone, 2021, 1, 7)
            ],
          ]));
    });
  });

  ft.group('NowAndFutureDay', () {
    ft.test(
        'the calculated future day is one minute past the beginning of the future day',
        () {
      var nafd = c.NowAndFutureDay(dayOffset: 1);
      var futureDay = nafd.now.add(const Duration(days: 1));
      var truncatedFutureDay = tz.TZDateTime(
          s.timeZone, futureDay.year, futureDay.month, futureDay.day, 0, 1);
      ft.expect(nafd.futureDay, ft.equals(truncatedFutureDay));
    });

    ft.test(
        'the calculated future day is one minute past the beginning of the future day for dayOffsets greater than 1',
        () {
      var nafd = c.NowAndFutureDay(dayOffset: 5);
      var futureDay = nafd.now.add(const Duration(days: 5));
      var truncatedFutureDay = tz.TZDateTime(
          s.timeZone, futureDay.year, futureDay.month, futureDay.day, 0, 1);
      ft.expect(nafd.futureDay, ft.equals(truncatedFutureDay));
    });
  });

  ft.group('throttledRequestIterable()', () {
    ft.test('it returns a single Uri when iterating over the last two days',
        () {
      var now = s.timeZoneNow();
      var iterator = c.Client.build()
          .uriIterable(startDate: now.subtract(const Duration(days: 2)))
          .iterator;
      iterator.moveNext();
      Uri uri = iterator.current;
      ft.expect(uri.path, ft.equals('/v1/apod'));
      ft.expect({...uri.queryParameters.keys},
          ft.equals({'thumbs', 'start_date', 'end_date'}));
      ft.expect(
          uri.queryParameters['start_date'],
          ft.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 2)))));
      ft.expect(
          uri.queryParameters['end_date'],
          ft.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 0)))));
      ft.expect(iterator.moveNext(), ft.equals(false));
    });

    ft.test(
        'it returns two Uris when iterating over the a date range with more days that Client.numMediaMetadataPerCall',
        () {
      var now = s.timeZoneNow();
      var iterator = c.Client.build()
          .uriIterable(
              startDate: now.subtract(
                  const Duration(days: c.Client.numMediaMetadataPerCall + 2)))
          .iterator;
      iterator.moveNext();
      var uri = iterator.current;
      ft.expect(uri.path, ft.equals('/v1/apod'));
      ft.expect({...uri.queryParameters.keys},
          ft.equals({'thumbs', 'start_date', 'end_date'}));
      ft.expect(
          uri.queryParameters['start_date'],
          ft.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(
                  days: c.Client.numMediaMetadataPerCall + 2)))));
      ft.expect(
          uri.queryParameters['end_date'],
          ft.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 3)))));
      ft.expect(iterator.moveNext(), ft.equals(true));
      uri = iterator.current;
      ft.expect(
          uri.queryParameters['start_date'],
          ft.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 2)))));
      ft.expect(
          uri.queryParameters['end_date'],
          ft.equals(s.yearMonthDayStringFromDateTime(
              dateTime: now.subtract(const Duration(days: 0)))));
      ft.expect(iterator.moveNext(), ft.equals(false));
    });
  });
}
