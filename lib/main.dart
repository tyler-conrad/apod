import 'package:flutter/material.dart' as m;

import 'apod.dart' as a;

Future<void> main() async {
  await a.setup();
  await a.buildController();

  m.runApp(
    m.MaterialApp(
      title: 'NASA Astronomy Picture of the Day',
      darkTheme: m.ThemeData.dark(),
      themeMode: m.ThemeMode.dark,
      navigatorKey: a.navigatorKey,
      navigatorObservers: [
        a.routeObserver,
      ],
      initialRoute: a.RouteStringConstants.populateDatabase,
      onGenerateRoute: (
        m.RouteSettings settings,
      ) {
        var route = settings.name!;
        a.logger.i('Switching to route: $route');
        a.routeHistory.push(route);
        switch (route) {
          case a.RouteStringConstants.populateDatabase:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => const m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 0.0,
                  child: a.PopulateDatabasePage(),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.home:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => const m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 64.0,
                  child: a.HomeScreen(),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.slideShow:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => const m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: a.SlideShow(
                    lookupByDateMode: false,
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.browseEarliest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: a.VerticalScrollBrowser(
                    mediaMetadataIterable: a.controller.fromEarliestForward(),
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.browseLatest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: a.VerticalScrollBrowser(
                    mediaMetadataIterable: a.controller.fromLatestBackward(),
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.swipeEarliest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: a.PageViewSwiper(
                    mediaMetadataIterable: a.controller.fromEarliestForward(),
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.swipeLatest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: a.PageViewSwiper(
                    mediaMetadataIterable: a.controller.fromLatestBackward(),
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.galleryEarliest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: a.Gallery(
                    mediaMetadataByMonth: a.controller.mediaMetadataByMonth(
                      mediaMetadataIterable: a.controller.fromEarliestForward(),
                    ),
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.galleryLatest:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: a.Gallery(
                    mediaMetadataByMonth: a.controller.mediaMetadataByMonth(
                      mediaMetadataIterable: a.controller.fromLatestBackward(),
                    ),
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.lookupByDate:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => const m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: a.SlideShow(
                    lookupByDateMode: true,
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.singleImageView:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: a.ApodScaffold(
                  leadingWidth: 128.0,
                  child: m.Builder(
                    builder: (context) {
                      var screenSize = m.MediaQuery.of(context).size;
                      var appBarHeight =
                          m.Scaffold.of(context).appBarMaxHeight!;
                      return a.SingleImageView(
                        fillHeightSize: screenSize.height - appBarHeight,
                        headerHeight: 0.0,
                        mediaMetadata: (settings.arguments as a.PushArguments)
                            .mediaMetadata!,
                      );
                    },
                  ),
                ),
              ),
              settings: settings,
            );

          case a.RouteStringConstants.interactiveViewer:
            return m.MaterialPageRoute(
              builder: (m.BuildContext context) => m.Material(
                child: a.InteractiveViewer(
                  mediaMetadata:
                      (settings.arguments as a.PushArguments).mediaMetadata!,
                  previousRoute: a.routeHistory[0],
                ),
              ),
              settings: settings,
            );

          default:
            throw a.InvalidRouteException('Invalid route: ${settings.name}');
        }
      },
    ),
  );
}
