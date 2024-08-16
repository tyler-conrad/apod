import 'dart:async' as async;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' as m;
import 'package:flutter_spinkit/flutter_spinkit.dart' as sk;
import 'package:transparent_image/transparent_image.dart' as t;

import '../media_metadata.dart' as mm;
import 'appearance.dart' as a;
import 'image_interaction.dart' as ii;

/// A widget for displaying a single image.
///
/// The image is displayed with a spinner while it is loading and is displayed
/// with a fade-in animation. It can be tapped to display the explanation and
/// date. The image can be tapped again to hide the explanation and date.
class SingleImageView extends m.StatefulWidget {
  final double? _fillHeightSize;
  final double _headerHeight;
  final mm.MediaMetadata _mediaMetadata;

  @override
  m.State<m.StatefulWidget> createState() => _SingleImageViewState();
  const SingleImageView({
    super.key,
    required double headerHeight,
    required mm.MediaMetadata mediaMetadata,
    double? fillHeightSize,
  })  : _fillHeightSize = fillHeightSize,
        _headerHeight = headerHeight,
        _mediaMetadata = mediaMetadata;
}

class _SingleImageViewState extends m.State<SingleImageView>
    with m.SingleTickerProviderStateMixin {
  final double spinnerSize = 256.0;
  final double copyrightInset = 16.0;

  final m.ValueNotifier<bool> buttonBoxActive = m.ValueNotifier(false);
  final m.ValueNotifier<bool> imageLoaded = m.ValueNotifier(false);

  late final m.AnimationController fadeInController;
  late final m.Animation<double> fadeInAnimation;

  @override
  void initState() {
    super.initState();
    fadeInController = m.AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    fadeInAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: fadeInController,
        curve: m.Curves.easeIn,
      ),
    );

    imageLoaded.addListener(
      () {
        if (imageLoaded.value) {
          fadeInController.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    buttonBoxActive.dispose();
    imageLoaded.dispose();
    fadeInController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    final screenSize = m.MediaQuery.of(context).size;
    final theme = m.Theme.of(context);
    final appBarHeight = m.Scaffold.of(context).appBarMaxHeight!;

    var image = m.Image.network(
      widget._mediaMetadata.hdUrl!,
      alignment: m.Alignment.center,
      fit: m.BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );

    final completer = async.Completer<ui.Image>();

    image.image.resolve(const m.ImageConfiguration()).addListener(
      m.ImageStreamListener(
        (info, syncCall) {
          if (mounted) {
            imageLoaded.value = true;
          }
          return completer.complete(info.image);
        },
      ),
    );

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
          child: m.Center(
            child: sk.SpinKitFadingCircle(
              color: theme.highlightColor,
              size: spinnerSize,
            ),
          ),
        ),
        m.GestureDetector(
          onTap: () {
            if (imageLoaded.value) {
              buttonBoxActive.value = !buttonBoxActive.value;
            }
          },
          child: ii.ImageInteraction(
            mediaMetadata: widget._mediaMetadata,
            showDate: false,
            buttonBoxActive: buttonBoxActive,
            child: m.FutureBuilder<ui.Image>(
              future: completer.future,
              builder:
                  (m.BuildContext context, m.AsyncSnapshot<ui.Image> snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!;
                  var imageAspect = data.width / data.height;
                  var stackHeight = screenSize.height - appBarHeight;
                  var stackAspect = screenSize.width / stackHeight;
                  double width;
                  double height;
                  if (widget._fillHeightSize != null) {
                    if (imageAspect > stackAspect) {
                      width = (stackHeight / imageAspect) * screenSize.width;
                      height = widget._fillHeightSize!;
                    } else {
                      width = screenSize.width;
                      height = (screenSize.width * imageAspect) * stackHeight;
                    }
                  } else {
                    width = screenSize.width;
                    height = screenSize.width / imageAspect;
                  }
                  return m.FadeTransition(
                    opacity: fadeInAnimation,
                    child: m.Center(
                      child: m.SizedBox(
                        width: width,
                        height: height,
                        child: image,
                      ),
                    ),
                  );
                } else {
                  return m.Image.memory(
                    t.kTransparentImage,
                    width: screenSize.width,
                    height: screenSize.height - widget._headerHeight,
                  );
                }
              },
            ),
          ),
        ),
        m.Positioned(
          right: copyrightInset,
          bottom: copyrightInset,
          child: m.FadeTransition(
            opacity: fadeInAnimation,
            child: m.Text(
              widget._mediaMetadata.copyrightWithSymbol,
              style: m.TextStyle(
                shadows: a.shadows(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
