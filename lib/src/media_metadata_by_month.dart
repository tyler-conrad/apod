import 'package:timezone/timezone.dart' as tz;
import 'package:equatable/equatable.dart' as eq;

import 'media_metadata.dart' as mm;

class MonthAndYear extends eq.Equatable {
  final int month;
  final int year;

  @override
  List<int> get props => [month, year];

  factory MonthAndYear.fromDateTime({required tz.TZDateTime dateTime}) {
    return MonthAndYear(month: dateTime.month, year: dateTime.year);
  }

  const MonthAndYear({
    required this.month,
    required this.year,
  });
}

class MediaMetadataByMonth {
  final MonthAndYear monthAndYear;
  final List<mm.MediaMetadata> mediaMetadataForMonth;

  const MediaMetadataByMonth(
      {required this.monthAndYear, required this.mediaMetadataForMonth});
}
