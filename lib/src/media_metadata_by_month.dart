import 'package:timezone/timezone.dart' as tz;
import 'package:equatable/equatable.dart' as eq;

import 'media_metadata.dart' as mm;

/// A class for storing the month and year.
///
/// This class is used to store the month and year of a [tz.TZDateTime] object.
class MonthAndYear extends eq.Equatable {
  final int month;
  final int year;

  @override
  List<int> get props => [month, year];

  MonthAndYear({required tz.TZDateTime dateTime})
      : month = dateTime.month,
        year = dateTime.year;
}

/// A class for storing media metadata by month.
///
/// This class is used to store a list of [mm.MediaMetadata] objects for a given
/// month and year.
class MediaMetadataByMonth {
  final MonthAndYear monthAndYear;
  final List<mm.MediaMetadata> mediaMetadataForMonth;

  const MediaMetadataByMonth(
      {required this.monthAndYear, required this.mediaMetadataForMonth});
}
