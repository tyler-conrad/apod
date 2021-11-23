import 'package:timezone/browser.dart' as browser;

Future<void> setup() async {
  await browser.initializeTimeZone();
}
