import 'package:flutter/material.dart' as m;

import 'shared.dart' as ws;
import 'appearance.dart' as a;
import 'slideshow.dart' as s;

class HomeScreenMenu extends m.StatelessWidget {
  m.MaterialButton buildMenuButton(
      {required String onPressedRoute, required String text}) {
    return m.MaterialButton(
      padding: a.edgeInsets24,
      onPressed: () => ws.navigatorKey.currentState?.pushNamed(
        onPressedRoute,
      ),
      child: m.Text(
        text,
        style: const m.TextStyle(
          fontSize: 24.0,
        ),
      ),
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.Center(
      child: m.SizedBox(
        width: 256.0,
        child: a.buildBox(
          theme: theme,
          child: m.Padding(
            padding: a.edgeInsets16,
            child: m.Column(
              mainAxisSize: m.MainAxisSize.min,
              mainAxisAlignment: m.MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: m.CrossAxisAlignment.stretch,
              children: [
                buildMenuButton(
                  onPressedRoute: ws.RouteStringConstants.slideShow,
                  text: ws.NameStringConstants.slideShow,
                ),
                buildMenuButton(
                  onPressedRoute: ws.RouteStringConstants.browseEarliest,
                  text: ws.NameStringConstants.browseEarliest,
                ),
                buildMenuButton(
                  onPressedRoute: ws.RouteStringConstants.browseLatest,
                  text: ws.NameStringConstants.browseLatest,
                ),
                buildMenuButton(
                  onPressedRoute: ws.RouteStringConstants.swipeEarliest,
                  text: ws.NameStringConstants.swipeEarliest,
                ),
                buildMenuButton(
                  onPressedRoute: ws.RouteStringConstants.swipeLatest,
                  text: ws.NameStringConstants.swipeLatest,
                ),
                buildMenuButton(
                  onPressedRoute: ws.RouteStringConstants.galleryEarliest,
                  text: ws.NameStringConstants.galleryEarliest,
                ),
                buildMenuButton(
                  onPressedRoute: ws.RouteStringConstants.galleryLatest,
                  text: ws.NameStringConstants.galleryLatest,
                ),
                buildMenuButton(
                  onPressedRoute: ws.RouteStringConstants.lookupByDate,
                  text: ws.NameStringConstants.lookupByDate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  const HomeScreenMenu({super.key});
}

class HomeScreen extends m.StatelessWidget {
  @override
  m.Widget build(m.BuildContext context) {
    return const s.SlideShow(
      lookupByDateMode: false,
      homeScreenMenu: HomeScreenMenu(),
    );
  }

  const HomeScreen({super.key});
}
