import 'package:flutter/material.dart' as m;
import 'package:transparent_image/transparent_image.dart' as t;

import 'shared.dart' as ws;
import '../media_metadata.dart' as mm;

class InteractiveViewer extends m.StatelessWidget {
  final double _closeIconInset = 16.0;
  final mm.MediaMetadata _mediaMetadata;
  final String _previousRoute;

  @override
  m.Widget build(m.BuildContext context) {
    return m.Stack(
      children: [
        m.InteractiveViewer(
          minScale: 1.0,
          maxScale: 6.0,
          child: ws.buildWidgetFillFadeInImage(
            placeholder: t.kTransparentImage,
            image: _mediaMetadata.hdUrl!,
          ),
        ),
        m.Positioned(
          top: _closeIconInset,
          right: _closeIconInset,
          child: m.IconButton(
            onPressed: () {
              return ws.navigatorKey.currentState?.pop(
                ws.PushArguments(
                  previousRoute: _previousRoute,
                  mediaMetadata: _mediaMetadata,
                ),
              );
            },
            icon: const m.Icon(
              m.Icons.close,
            ),
          ),
        ),
      ],
    );
  }

  const InteractiveViewer(
      {m.Key? key,
      required mm.MediaMetadata mediaMetadata,
      required String previousRoute})
      : _previousRoute = previousRoute,
        _mediaMetadata = mediaMetadata,
        super(key: key);
}
