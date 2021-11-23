import 'package:flutter/material.dart' as m;

import 'shared.dart' as ws;
import 'drawer.dart' as d;

final m.ValueNotifier<d.DrawerState> _activeDrawerState =
    m.ValueNotifier<d.DrawerState>(d.DrawerState.populateDatabase);

String title = 'Populate Database';

class _ApodScaffoldState extends m.State<ApodScaffold> with m.RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ws.routeObserver.subscribe(
      this,
      m.ModalRoute.of(context) as m.MaterialPageRoute,
    );
  }

  @override
  void didPushNext() {
    ws.navigatorKey.currentState?.popUntil(
      (route) {
        switch (route.settings.name) {
          case ws.RouteStringConstants.populateDatabase:
            setState(
              () {
                title = ws.NameStringConstants.populateDatabase;
              },
            );
            break;

          case ws.RouteStringConstants.home:
            _activeDrawerState.value = d.DrawerState.homeScreen;
            setState(
              () {
                title = ws.NameStringConstants.home;
              },
            );
            break;

          case ws.RouteStringConstants.slideShow:
            _activeDrawerState.value = d.DrawerState.slideShow;
            setState(
              () {
                title = ws.NameStringConstants.slideShow;
              },
            );
            break;

          case ws.RouteStringConstants.browseEarliest:
            _activeDrawerState.value = d.DrawerState.browseEarliest;
            setState(
              () {
                title = ws.NameStringConstants.browseEarliest;
              },
            );
            break;

          case ws.RouteStringConstants.browseLatest:
            _activeDrawerState.value = d.DrawerState.browseLatest;
            setState(
              () {
                title = ws.NameStringConstants.browseLatest;
              },
            );
            break;

          case ws.RouteStringConstants.swipeEarliest:
            _activeDrawerState.value = d.DrawerState.swipeEarliest;
            setState(
              () {
                title = ws.NameStringConstants.swipeEarliest;
              },
            );
            break;

          case ws.RouteStringConstants.swipeLatest:
            _activeDrawerState.value = d.DrawerState.swipeLatest;
            setState(
              () {
                title = ws.NameStringConstants.swipeLatest;
              },
            );
            break;

          case ws.RouteStringConstants.galleryEarliest:
            _activeDrawerState.value = d.DrawerState.galleryEarliest;
            setState(
              () {
                title = ws.NameStringConstants.galleryEarliest;
              },
            );
            break;

          case ws.RouteStringConstants.galleryLatest:
            _activeDrawerState.value = d.DrawerState.galleryLatest;
            setState(
              () {
                title = ws.NameStringConstants.galleryLatest;
              },
            );
            break;

          case ws.RouteStringConstants.lookupByDate:
            _activeDrawerState.value = d.DrawerState.lookupByDate;
            setState(
              () {
                title = ws.NameStringConstants.lookupByDate;
              },
            );
            break;

          case ws.RouteStringConstants.singleImageView:
            setState(
              () {
                title = ws.NameStringConstants.singleImageView;
              },
            );
            break;

          case ws.RouteStringConstants.interactiveViewer:
            break;

          case null:
            break;

          default:
            throw Exception(
              'Unsupported route: ${route.settings.name}',
            );
        }
        return true;
      },
    );
  }

  @override
  void dispose() {
    ws.routeObserver.unsubscribe(
      this,
    );
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    var screenSize = m.MediaQuery.of(context).size;
    var appBar = m.AppBar(
      title: m.Text(title),
      centerTitle: true,
      leadingWidth: widget._leadingWidth,
      automaticallyImplyLeading: false,
      leading: m.Row(
        mainAxisAlignment: m.MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: m.CrossAxisAlignment.stretch,
        mainAxisSize: m.MainAxisSize.max,
        children: [
          if (_activeDrawerState.value != d.DrawerState.populateDatabase)
            m.Expanded(
              child: m.Builder(
                builder: (m.BuildContext context) {
                  return m.MaterialButton(
                    child: const m.Icon(
                      m.Icons.menu,
                    ),
                    onPressed: () {
                      m.Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),
          if (_activeDrawerState.value != d.DrawerState.populateDatabase &&
              _activeDrawerState.value != d.DrawerState.homeScreen)
            m.Expanded(
              child: m.MaterialButton(
                child: const m.Icon(
                  m.Icons.arrow_back,
                ),
                onPressed: () {
                  ws.navigatorKey.currentState?.pop();
                },
              ),
            ),
        ],
      ),
    );
    return m.SafeArea(
      child: m.Overlay(
        initialEntries: [
          m.OverlayEntry(
            builder: (context) => m.Scaffold(
              drawer: m.ValueListenableBuilder<d.DrawerState>(
                valueListenable: _activeDrawerState,
                builder: (
                  _context,
                  activeDrawerState,
                  child,
                ) {
                  return d.ApodDrawer(
                    activeDrawerState: activeDrawerState,
                  );
                },
              ),
              appBar: appBar,
              body: m.SizedBox(
                width: screenSize.width,
                height: screenSize.height - appBar.preferredSize.height,
                child: widget._child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ApodScaffold extends m.StatefulWidget {
  final m.Widget _child;
  final double _leadingWidth;

  @override
  m.State<m.StatefulWidget> createState() => _ApodScaffoldState();

  const ApodScaffold(
      {m.Key? key, required double leadingWidth, required m.Widget child})
      : _leadingWidth = leadingWidth,
        _child = child,
        super(key: key);
}
