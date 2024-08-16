import 'package:timezone/browser.dart' as browser;

/// Initialize Time zone database.
Future<void> setup() async {
  await browser.initializeTimeZone();
}
