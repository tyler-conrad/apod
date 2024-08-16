import 'package:flutter/material.dart' as m;
import 'package:sticky_headers/sticky_headers.dart' as sh;

import '../shared.dart' as s;
import '../media_metadata.dart' as mm;
import 'single_image_view.dart' as siv;

/// A widget for browsing images in a vertical scroll view.
///
/// The images are displayed in a vertical scroll view with a header for each
/// date. They can be tapped to view the image in fullscreen.
class VerticalScrollBrowser extends m.StatefulWidget {
  final double _headerHeight = 48.0;
  final Iterable<mm.MediaMetadata> _mediaMetadataIterable;

  @override
  m.State<m.StatefulWidget> createState() => _VerticalScrollBrowserState();

  const VerticalScrollBrowser(
      {super.key, required Iterable<mm.MediaMetadata> mediaMetadataIterable})
      : _mediaMetadataIterable = mediaMetadataIterable;
}

class _VerticalScrollBrowserState extends m.State<VerticalScrollBrowser> {
  late final Map<int, mm.MediaMetadata> mediaMetadataFromIndex;

  @override
  void initState() {
    super.initState();
    mediaMetadataFromIndex = widget._mediaMetadataIterable.toList().asMap();
  }

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.Stack(
      children: [
        m.Positioned.fill(
          child: m.DecoratedBox(
            decoration: m.BoxDecoration(
              color: theme.primaryColor,
            ),
          ),
        ),
        m.Positioned.fill(
          child: m.ListView.builder(
            itemCount: mediaMetadataFromIndex.length,
            itemBuilder: (
              context,
              index,
            ) {
              return sh.StickyHeader(
                header: m.SizedBox(
                  height: widget._headerHeight,
                  child: m.DecoratedBox(
                    decoration: m.BoxDecoration(
                      color: theme.primaryColor,
                    ),
                    child: m.Center(
                      child: m.Text(
                        s.dateStringFromDateTime(
                          dateTime: mediaMetadataFromIndex[index]!.date,
                        ),
                      ),
                    ),
                  ),
                ),
                content: siv.SingleImageView(
                  headerHeight: widget._headerHeight,
                  mediaMetadata: mediaMetadataFromIndex[index]!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
