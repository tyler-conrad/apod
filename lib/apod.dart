/// This library provides a Flutter app to browse images provided by NASA on a
/// daily basis.
///
/// It uses the [apod-api](https://github.com/nasa/apod-api) project
/// to provide image metadata including links scraped from the [Astronomy
/// Picture of the Day](https://apod.nasa.gov/apod/astropix.html) website.
library;

export 'src/log.dart';
export 'src/widget/shared.dart';
export 'src/controller.dart';
export 'src/widget/scaffold.dart';
export 'src/widget/populate_database_page.dart';
export 'src/widget/home_screen.dart';
export 'src/widget/slideshow.dart';
export 'src/widget/vertical_scroll_browser.dart';
export 'src/widget/page_view_swiper.dart';
export 'src/widget/gallery.dart';
export 'src/widget/single_image_view.dart';
export 'src/widget/interactive_viewer.dart';
export 'src/tz/timezone_stub.dart'
    if (dart.library.io) 'src/tz/timezone_flutter.dart'
    if (dart.library.js) 'src/tz/timezone_web.dart';
