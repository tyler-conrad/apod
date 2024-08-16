import 'package:flutter/material.dart' as m;
import 'package:sticky_headers/sticky_headers.dart' as sh;

import '../shared.dart' as s;
import '../media_metadata_by_month.dart' as mmbm;
import 'thumbnail.dart' as t;

/// A gallery widget that displays media metadata in a grid.
class Gallery extends m.StatelessWidget {
  final int _thumbnailsPerRow = 5;
  final double _headerHeight = 48.0;
  late final Map<int, mmbm.MediaMetadataByMonth> _mediaMetadataByMonthFromIndex;

  Gallery({
    super.key,
    required Iterable<mmbm.MediaMetadataByMonth> mediaMetadataByMonth,
  }) : _mediaMetadataByMonthFromIndex = mediaMetadataByMonth.toList().asMap();

  @override
  m.Widget build(m.BuildContext context) {
    var screenSize = m.MediaQuery.of(context).size;
    var theme = m.Theme.of(context);
    var thumbnailSize = screenSize.width / _thumbnailsPerRow;
    return m.ListView.builder(
      itemCount: _mediaMetadataByMonthFromIndex.length,
      itemBuilder: (context, index) {
        var rowChunks = s.chunks(
            list: _mediaMetadataByMonthFromIndex[index]!.mediaMetadataForMonth,
            chunkSize: _thumbnailsPerRow);

        return sh.StickyHeader(
          header: m.SizedBox(
            height: _headerHeight,
            child: m.DecoratedBox(
              decoration: m.BoxDecoration(
                color: theme.primaryColor,
              ),
              child: m.Center(
                child: m.Text(
                  s.monthAndYearString(
                    monthAndYear:
                        _mediaMetadataByMonthFromIndex[index]!.monthAndYear,
                  ),
                ),
              ),
            ),
          ),
          content: m.Column(
            mainAxisSize: m.MainAxisSize.min,
            mainAxisAlignment: m.MainAxisAlignment.start,
            children: rowChunks.map(
              (rowChunk) {
                return m.Row(
                  mainAxisAlignment: m.MainAxisAlignment.start,
                  mainAxisSize: m.MainAxisSize.max,
                  children: rowChunk.map(
                    (mediaMetadata) {
                      return m.SizedBox(
                        width: thumbnailSize,
                        height: thumbnailSize,
                        child: t.Thumbnail(
                          mediaMetadata: mediaMetadata,
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}
