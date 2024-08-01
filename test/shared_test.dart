import 'package:flutter_test/flutter_test.dart' as ft;

import 'package:apod/src/shared.dart' as s;
import 'package:timezone/timezone.dart' as tz;
import 'package:apod/src/tz/timezone_stub.dart'
    if (dart.library.io) 'package:apod/src/tz/timezone_flutter.dart'
    if (dart.library.js) 'package:apod/src/tz/timezone_web.dart' as timezone;

void main() {
  ft.setUp(() async {
    await timezone.setup();
  });

  ft.group('parseDate()', () {
    ft.test('Parses year, month and day into a DateTime', () {
      timezone.setup();
      DateTime dt = s.parseDate(dateString: '2021-01-01');
      ft.expect(dt.year, ft.equals(2021));
      ft.expect(dt.month, ft.equals(1));
      ft.expect(dt.day, ft.equals(1));
    });

    ft.test(
        'throws ParseDateMatchException on when the _dateRegExp finds no matches',
        () {
      ft.expect(() => s.parseDate(dateString: 'invalid'),
          ft.throwsA(ft.isA<s.ParseDateMatchException>()));
    });
  });

  ft.group('nowEastern()', () {
    ft.test('returns the correct hour offset when DST begins', () {
      ft.expect(
          DateTime.utc(2021, 3, 14, 3)
              .difference(tz.TZDateTime(s.timeZone, 2021, 3, 14, 2, 3))
              .inHours,
          ft.equals(-5));
    });

    ft.test('returns the correct hour offset directly before when DST begins',
        () {
      ft.expect(
          DateTime.utc(2021, 3, 14, 1, 59, 59)
              .difference(tz.TZDateTime(s.timeZone, 2021, 3, 14, 1, 59, 59))
              .inHours,
          ft.equals(-6));
    });

    ft.test('returns the correct hour offset when DST ends', () {
      ft.expect(
          DateTime.utc(2021, 11, 7, 2)
              .difference(tz.TZDateTime(s.timeZone, 2021, 11, 7, 2))
              .inHours,
          ft.equals(-6));
    });

    ft.test('returns the correct hour offset directly before DST ends', () {
      ft.expect(
          DateTime.utc(2021, 11, 7, 1, 59, 59)
              .difference(tz.TZDateTime(s.timeZone, 2021, 11, 7, 1, 59, 59))
              .inHours,
          ft.equals(-5));
    });
  });

  ft.group('dateStringFromDateTime', () {
    ft.test('returns the a date string in the format YYYY-MM-DD', () {
      ft.expect(
          s.yearMonthDayStringFromDateTime(
              dateTime: tz.TZDateTime(s.timeZone, 2021, 1, 1, 1, 1, 1)),
          ft.equals('2021-01-01'));
    });
  });

  ft.test('returns a single date when startDate equals endDate', () {
    ft.expect(
        s.dateIterable(
            startDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
            endDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
            offset: 50),
        ft.equals([tz.TZDateTime(s.timeZone, 2021, 1, 1)]));
  });

  ft.group('dateIterable', () {
    ft.test('returns an empty Iterable when the startDate is after the endDate',
        () {
      ft.expect(
          s
              .dateIterable(
                  startDate: tz.TZDateTime(s.timeZone, 2021, 1, 2),
                  endDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
                  offset: 1)
              .toList(),
          ft.equals([]));
    });

    ft.test('returns dates in ascending order with an offset of 1', () {
      ft.expect(
          s
              .dateIterable(
                  startDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
                  endDate: tz.TZDateTime(s.timeZone, 2021, 1, 5),
                  offset: 1)
              .toList(),
          ft.equals([
            tz.TZDateTime(s.timeZone, 2021, 1, 1),
            tz.TZDateTime(s.timeZone, 2021, 1, 2),
            tz.TZDateTime(s.timeZone, 2021, 1, 3),
            tz.TZDateTime(s.timeZone, 2021, 1, 4),
            tz.TZDateTime(s.timeZone, 2021, 1, 5),
          ]));
    });

    ft.test(
        'returns dates in ascending order with an offset of 2 including the endDate',
        () {
      ft.expect(
          s
              .dateIterable(
                  startDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
                  endDate: tz.TZDateTime(s.timeZone, 2021, 1, 6),
                  offset: 2)
              .toList(),
          ft.equals([
            tz.TZDateTime(s.timeZone, 2021, 1, 1),
            tz.TZDateTime(s.timeZone, 2021, 1, 3),
            tz.TZDateTime(s.timeZone, 2021, 1, 5),
            tz.TZDateTime(s.timeZone, 2021, 1, 6)
          ]));
    });
  });
}
