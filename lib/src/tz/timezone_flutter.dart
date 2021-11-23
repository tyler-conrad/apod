import 'package:timezone/data/latest.dart' as latest;

Future<void> setup() async {
  latest.initializeTimeZones();
}
