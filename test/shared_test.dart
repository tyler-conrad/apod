import 'package:apod/src/shared.dart' as s;
import 'package:test/test.dart' as t;
import 'package:timezone/timezone.dart' as tz;

import 'package:apod/src/tz/timezone_stub.dart'
    if (dart.library.io) 'package:apod/src/tz/timezone_flutter.dart'
    if (dart.library.js) 'package:apod/src/tz/timezone_web.dart' as timezone;

void main() {
  t.setUp(() async {
    await timezone.setup();
  });

  t.group('parseDate()', () {
    t.test('Parses year, month and day into a DateTime', () {
      timezone.setup();
      DateTime dt = s.parseDate(dateString: '2021-01-01');
      t.expect(dt.year, t.equals(2021));
      t.expect(dt.month, t.equals(1));
      t.expect(dt.day, t.equals(1));
    });

    t.test(
        'throws ParseDateMatchException on when the _dateRegExp finds no matches',
        () {
      t.expect(() => s.parseDate(dateString: 'invalid'),
          t.throwsA(t.isA<s.ParseDateMatchException>()));
    });
  });

  t.group('nowEastern()', () {
    t.test('returns the correct hour offset when DST begins', () {
      t.expect(
          DateTime.utc(2021, 3, 14, 2)
              .difference(tz.TZDateTime(s.timeZone, 2021, 3, 14, 2))
              .inHours,
          t.equals(-5));
    });

    t.test('returns the correct hour offset directly before when DST begins',
        () {
      t.expect(
          DateTime.utc(2021, 3, 14, 1, 59, 59)
              .difference(tz.TZDateTime(s.timeZone, 2021, 3, 14, 1, 59, 59))
              .inHours,
          t.equals(-6));
    });

    t.test('returns the correct hour offset when DST ends', () {
      t.expect(
          DateTime.utc(2021, 11, 7, 2)
              .difference(tz.TZDateTime(s.timeZone, 2021, 11, 7, 2))
              .inHours,
          t.equals(-6));
    });

    t.test('returns the correct hour offset directly before DST ends', () {
      t.expect(
          DateTime.utc(2021, 11, 7, 1, 59, 59)
              .difference(tz.TZDateTime(s.timeZone, 2021, 11, 7, 1, 59, 59))
              .inHours,
          t.equals(-5));
    });
  });

  t.group('dateStringFromDateTime', () {
    t.test('returns the a date string in the format YYYY-MM-DD', () {
      t.expect(
          s.yearMonthDayStringFromDateTime(
              dateTime: tz.TZDateTime(s.timeZone, 2021, 1, 1, 1, 1, 1)),
          t.equals('2021-01-01'));
    });
  });

  t.test('returns a single date when startDate equals endDate', () {
    t.expect(
        s.dateIterable(
            startDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
            endDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
            offset: 50),
        t.equals([tz.TZDateTime(s.timeZone, 2021, 1, 1)]));
  });

  t.group('dateIterable', () {
    t.test('returns an empty Iterable when the startDate is after the endDate',
        () {
      t.expect(
          s
              .dateIterable(
                  startDate: tz.TZDateTime(s.timeZone, 2021, 1, 2),
                  endDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
                  offset: 1)
              .toList(),
          t.equals([]));
    });

    t.test('returns dates in ascending order with an offset of 1', () {
      t.expect(
          s
              .dateIterable(
                  startDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
                  endDate: tz.TZDateTime(s.timeZone, 2021, 1, 5),
                  offset: 1)
              .toList(),
          t.equals([
            tz.TZDateTime(s.timeZone, 2021, 1, 1),
            tz.TZDateTime(s.timeZone, 2021, 1, 2),
            tz.TZDateTime(s.timeZone, 2021, 1, 3),
            tz.TZDateTime(s.timeZone, 2021, 1, 4),
            tz.TZDateTime(s.timeZone, 2021, 1, 5),
          ]));
    });

    t.test(
        'returns dates in ascending order with an offset of 2 including the endDate',
        () {
      t.expect(
          s
              .dateIterable(
                  startDate: tz.TZDateTime(s.timeZone, 2021, 1, 1),
                  endDate: tz.TZDateTime(s.timeZone, 2021, 1, 6),
                  offset: 2)
              .toList(),
          t.equals([
            tz.TZDateTime(s.timeZone, 2021, 1, 1),
            tz.TZDateTime(s.timeZone, 2021, 1, 3),
            tz.TZDateTime(s.timeZone, 2021, 1, 5),
            tz.TZDateTime(s.timeZone, 2021, 1, 6)
          ]));
    });
  });
}
