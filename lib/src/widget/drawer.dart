import 'package:flutter/material.dart' as m;

import 'shared.dart' as ws;

enum DrawerState {
  populateDatabase,
  homeScreen,
  slideShow,
  browseEarliest,
  browseLatest,
  swipeEarliest,
  swipeLatest,
  galleryEarliest,
  galleryLatest,
  lookupByDate,
}

class ApodDrawer extends m.StatelessWidget {
  final DrawerState _activeDrawerState;

  m.IconData iconFromDrawerState({required DrawerState drawerState}) {
    switch (drawerState) {
      case DrawerState.populateDatabase:
        return m.Icons.close;
      case DrawerState.homeScreen:
        return m.Icons.home;
      case DrawerState.slideShow:
        return m.Icons.slideshow;
      case DrawerState.browseEarliest:
        return m.Icons.arrow_forward;
      case DrawerState.browseLatest:
        return m.Icons.arrow_back;
      case DrawerState.swipeEarliest:
        return m.Icons.arrow_right;
      case DrawerState.swipeLatest:
        return m.Icons.arrow_left;
      case DrawerState.galleryEarliest:
        return m.Icons.keyboard_arrow_right_rounded;
      case DrawerState.galleryLatest:
        return m.Icons.keyboard_arrow_left_rounded;
      case DrawerState.lookupByDate:
        return m.Icons.calendar_today;
    }
  }

  m.Expanded buildDrawerButton({
    required m.BuildContext context,
    required m.ThemeData theme,
    required DrawerState thisDrawerState,
    required DrawerState activeDrawerState,
    required String routeToPush,
  }) {
    return m.Expanded(
      child: m.Builder(
        builder: (m.BuildContext context) {
          return m.MaterialButton(
            minWidth: double.infinity,
            color: activeDrawerState == thisDrawerState
                ? theme.highlightColor
                : theme.primaryColor,
            onPressed: activeDrawerState == thisDrawerState
                ? null
                : () {
                    ws.navigatorKey.currentState?.pushNamed(routeToPush);
                    m.Scaffold.of(context).openEndDrawer();
                  },
            child: m.Icon(
              iconFromDrawerState(
                drawerState: thisDrawerState,
              ),
              size: 96.0,
            ),
          );
        },
      ),
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.Drawer(
      child: m.Column(
        mainAxisAlignment: m.MainAxisAlignment.spaceEvenly,
        children: [
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.homeScreen,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.home,
          ),
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.slideShow,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.slideShow,
          ),
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.browseEarliest,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.browseEarliest,
          ),
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.browseLatest,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.browseLatest,
          ),
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.swipeEarliest,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.swipeEarliest,
          ),
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.swipeLatest,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.swipeLatest,
          ),
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.galleryEarliest,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.galleryEarliest,
          ),
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.galleryLatest,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.galleryLatest,
          ),
          buildDrawerButton(
            context: context,
            theme: theme,
            thisDrawerState: DrawerState.lookupByDate,
            activeDrawerState: _activeDrawerState,
            routeToPush: ws.RouteStringConstants.lookupByDate,
          ),
        ],
      ),
    );
  }

  const ApodDrawer({super.key, required DrawerState activeDrawerState})
      : _activeDrawerState = activeDrawerState;
}
