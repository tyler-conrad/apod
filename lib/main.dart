import 'package:flutter/material.dart' as m;

import 'src/log.dart' as l;
import 'src/widget/shared.dart' as ws;
import 'src/controller.dart' as c;
import 'src/widget/scaffold.dart' as s;
import 'src/widget/populate_database_page.dart' as pdp;
import 'src/widget/home_screen.dart' as hs;
import 'src/widget/slideshow.dart' as ss;
import 'src/widget/vertical_scroll_browser.dart' as vsb;
import 'src/widget/page_view_swiper.dart' as pvs;
import 'src/widget/gallery.dart' as g;
import 'src/widget/single_image_view.dart' as siv;
import 'src/widget/interactive_viewer.dart' as iv;
import 'src/tz/timezone_stub.dart'
    if (dart.library.io) 'src/tz/timezone_flutter.dart'
    if (dart.library.js) 'src/tz/timezone_web.dart' as timezone;

Future<void> main() async {
  await timezone.setup();
  await c.buildController();

  m.runApp(
    m.MaterialApp(
      title: 'NASA Astronomy Picture of the Day',
      darkTheme: m.ThemeData.dark(),
      themeMode: m.ThemeMode.dark,
      navigatorKey: ws.navigatorKey,
      navigatorObservers: [
        ws.routeObserver,
      ],
      initialRoute: ws.RouteStringConstants.populateDatabase,
      onGenerateRoute: (
        m.RouteSettings settings,
      ) {
        var route = settings.name!;
        l.logger.i('Switching to route: $route');
        ws.routeHistory.push(route);
        switch (route) {
          case ws.RouteStringConstants.populateDatabase:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => const m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 0.0,
                  child: pdp.PopulateDatabasePage(),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.home:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => const m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 64.0,
                  child: hs.HomeScreen(),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.slideShow:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => const m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: ss.SlideShow(
                    lookupByDateMode: false,
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.browseEarliest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: vsb.VerticalScrollBrowser(
                    mediaMetadataIterable: c.controller.fromEarliestForward(),
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.browseLatest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: vsb.VerticalScrollBrowser(
                    mediaMetadataIterable: c.controller.fromLatestBackward(),
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.swipeEarliest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: pvs.PageViewSwiper(
                    mediaMetadataIterable: c.controller.fromEarliestForward(),
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.swipeLatest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: pvs.PageViewSwiper(
                    mediaMetadataIterable: c.controller.fromLatestBackward(),
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.galleryEarliest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: g.Gallery(
                    mediaMetadataByMonth: c.controller.mediaMetadataByMonth(
                      mediaMetadataIterable: c.controller.fromEarliestForward(),
                    ),
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.galleryLatest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: g.Gallery(
                    mediaMetadataByMonth: c.controller.mediaMetadataByMonth(
                      mediaMetadataIterable: c.controller.fromLatestBackward(),
                    ),
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.lookupByDate:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => const m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: ss.SlideShow(
                    lookupByDateMode: true,
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.singleImageView:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: s.ApodScaffold(
                  leadingWidth: 128.0,
                  child: m.Builder(
                    builder: (context) {
                      var screenSize = m.MediaQuery.of(context).size;
                      var appBarHeight =
                          m.Scaffold.of(context).appBarMaxHeight!;
                      return siv.SingleImageView(
                        fillHeightSize: screenSize.height - appBarHeight,
                        headerHeight: 0.0,
                        mediaMetadata: (settings.arguments as ws.PushArguments)
                            .mediaMetadata!,
                      );
                    },
                  ),
                ),
              ),
              settings: settings,
            );

          case ws.RouteStringConstants.interactiveViewer:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: iv.InteractiveViewer(
                  mediaMetadata:
                      (settings.arguments as ws.PushArguments).mediaMetadata!,
                  previousRoute: ws.routeHistory[0],
                ),
              ),
              settings: settings,
            );

          default:
            throw ws.InvalidRouteException('Invalid route: ${settings.name}');
        }
      },
    ),
  );
}
