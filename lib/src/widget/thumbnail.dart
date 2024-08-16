import 'package:flutter/material.dart' as m;
import 'package:flutter_spinkit/flutter_spinkit.dart' as sk;
import 'package:transparent_image/transparent_image.dart' as t;

import '../media_metadata.dart' as mm;
import 'shared.dart' as ws;

/// A widget for displaying a thumbnail image.
///
/// The image is displayed with a spinner while it is loading and is displayed
/// with a fade-in animation. It can be tapped to view the image in fullscreen.
class Thumbnail extends m.StatefulWidget {
  final mm.MediaMetadata _mediaMetadata;

  @override
  m.State<m.StatefulWidget> createState() => _ThumbnailState();

  const Thumbnail({
    super.key,
    required mm.MediaMetadata mediaMetadata,
  }) : _mediaMetadata = mediaMetadata;
}

class _ThumbnailState extends m.State<Thumbnail> {
  bool imageLoaded = false;

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.Stack(
      children: [
        m.Positioned.fill(
          child: m.Center(
            child: sk.SpinKitFadingCircle(
              color: theme.highlightColor,
            ),
          ),
        ),
        m.Positioned.fill(
          child: m.GestureDetector(
            onTap: () {
              if (imageLoaded) {
                ws.navigatorKey.currentState?.pushNamed(
                  ws.RouteStringConstants.singleImageView,
                  arguments: ws.PushArguments(
                    mediaMetadata: widget._mediaMetadata,
                  ),
                );
              }
            },
            child: ws.buildWidgetFillFadeInImage(
              placeholder: t.kTransparentImage,
              image: widget._mediaMetadata.url!,
            )..image
                  .resolve(
                const m.ImageConfiguration(),
              )
                  .addListener(
                m.ImageStreamListener(
                  (info, syncCall) {
                    if (mounted) {
                      setState(
                        () {
                          imageLoaded = true;
                        },
                      );
                    }
                  },
                ),
              ),
          ),
        ),
      ],
    );
  }
}
