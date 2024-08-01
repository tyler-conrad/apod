import 'dart:typed_data' as td;

import 'package:flutter/material.dart' as m;

import '../shared.dart' as s;
import '../media_metadata.dart' as mm;

final m.Image placeholder = m.Image.asset(
  'assets/placeholder.jpg',
  alignment: m.Alignment.center,
  fit: m.BoxFit.cover,
  width: double.infinity,
  height: double.infinity,
);

final m.GlobalKey<m.NavigatorState> navigatorKey = m.GlobalKey();

final m.RouteObserver<m.ModalRoute<void>> routeObserver = m.RouteObserver();

class RouteStringConstants {
  static const String populateDatabase = '/';
  static const String home = '/home';
  static const String slideShow = '/slideShow';
  static const String browseEarliest = '/browseEarliest';
  static const String browseLatest = '/browseLatest';
  static const String swipeEarliest = '/swipeEarliest';
  static const String swipeLatest = '/swipeLatest';
  static const String galleryEarliest = '/galleryEarliest';
  static const String galleryLatest = '/galleryLatest';
  static const String lookupByDate = '/lookupByDate';
  static const String singleImageView = '/singleImageView';
  static const String interactiveViewer = '/interactiveViewer';
}

class NameStringConstants {
  static const String populateDatabase = 'Populate Database';
  static const String home = 'Home';
  static const String slideShow = 'SlideShow';
  static const String browseEarliest = 'Browse Earliest';
  static const String browseLatest = 'Browse Latest';
  static const String swipeEarliest = 'Swipe Earliest';
  static const String swipeLatest = 'Swipe Latest';
  static const String galleryEarliest = 'Gallery Earliest';
  static const String galleryLatest = 'GalleryLatest';
  static const String singleImageView = 'View Image';
  static const String lookupByDate = 'Lookup By Date';
}

final s.FixedLengthQueue<String> routeHistory =
    s.FixedLengthQueue(maxLength: 2);

class InvalidRouteException implements Exception {
  final String msg;
  const InvalidRouteException(this.msg);
}

m.FadeInImage buildWidgetFillFadeInImage({
  required td.Uint8List placeholder,
  required String image,
}) {
  return m.FadeInImage.memoryNetwork(
    placeholder: placeholder,
    image: image,
    alignment: m.Alignment.center,
    fit: m.BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
  );
}

class PushArguments {
  final String? previousRoute;
  final mm.MediaMetadata? mediaMetadata;

  const PushArguments({this.previousRoute, this.mediaMetadata});
}
