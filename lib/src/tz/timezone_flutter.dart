import 'package:timezone/data/latest.dart' as latest;

/// Initialize Time zone database.
Future<void> setup() async {
  latest.initializeTimeZones();
}
