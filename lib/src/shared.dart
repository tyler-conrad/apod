import 'dart:io' as io;
import 'dart:collection' as c;

import 'package:flutter/material.dart' as m;
import 'package:timezone/timezone.dart' as tz;

import 'shared.dart' as s;
import 'media_metadata_by_month.dart' as mmbm;

final m.Image nasaLogo = m.Image.file(
  io.File('assets/nasa_logo.png'),
  alignment: m.Alignment.center,
  fit: m.BoxFit.cover,
  width: double.infinity,
  height: double.infinity,
);

class ParseDateMatchException implements Exception {
  final String cause;
  ParseDateMatchException(this.cause);
}

final _dateRegExp = RegExp(r'(\d{4})\-(\d{2})-(\d{2})');
tz.TZDateTime parseDate({required String dateString}) {
  var match = _dateRegExp.firstMatch(dateString);
  if (match == null) {
    throw ParseDateMatchException(
        'The RegExp used for date string parsing failed to find a match');
  }
  var year = int.parse(match.group(1)!);
  var month = int.parse(match.group(2)!);
  var day = int.parse(match.group(3)!);
  return tz.TZDateTime(s.timeZone, year, month, day);
}

final tz.Location timeZone = tz.getLocation('America/Chicago');

tz.TZDateTime timeZoneNow() {
  return tz.TZDateTime.now(timeZone);
}

String yearMonthDayStringFromDateTime({required tz.TZDateTime dateTime}) {
  return dateTime.toString().substring(0, 10);
}

Iterable<tz.TZDateTime> dateIterable(
    {required tz.TZDateTime startDate,
    required tz.TZDateTime endDate,
    required int offset}) sync* {
  if (endDate.difference(startDate).inDays < 0) {
    return;
  }

  tz.TZDateTime currentDate = startDate;
  while (currentDate.compareTo(endDate) < 0) {
    yield currentDate;
    currentDate = currentDate.add(Duration(days: offset));
  }

  yield endDate;
}

List<List<T>> chunks<T>({required List<T> list, required int chunkSize}) {
  List<List<T>> chunks = [];
  for (var i = 0; i < list.length; i += chunkSize) {
    chunks.add(
      list.sublist(
        i,
        (i + chunkSize < list.length) ? i + chunkSize : list.length,
      ),
    );
  }
  return chunks;
}

String _stringFromMonth(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      throw Exception('Invalid month index in _stringFromMonth(): $month');
  }
}

String _stringFromDay(int day) {
  final String dayString = day.toString();
  final String lastDigit = dayString.substring(dayString.length - 1);
  switch (lastDigit) {
    case '1':
      return '${day}st';
    case '2':
      return '${day}nd';
    case '3':
      return '${day}rd';
    default:
      return '${day}th';
  }
}

String dateStringFromDateTime({required DateTime dateTime}) {
  return '${_stringFromMonth(dateTime.month)} ${_stringFromDay(dateTime.day)} ${dateTime.year}';
}

String monthAndYearString({required mmbm.MonthAndYear monthAndYear}) {
  return '${_stringFromMonth(monthAndYear.month)} ${monthAndYear.year}';
}

class FixedLengthQueue<E> {
  final int maxLength;
  final c.Queue<E> queue = c.Queue();

  void push(E element) {
    queue.add(element);
    while (queue.length > maxLength) {
      queue.removeFirst();
    }
  }

  E operator [](int index) {
    return queue.elementAt(index);
  }

  FixedLengthQueue({required this.maxLength});
}
