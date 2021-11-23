import 'dart:async' as async;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' as m;
import 'package:flutter_spinkit/flutter_spinkit.dart' as sk;
import 'package:transparent_image/transparent_image.dart' as t;

import '../media_metadata.dart' as mm;
import 'appearance.dart' as a;
import 'image_interaction.dart' as ii;

class _SingleImageViewState extends m.State<SingleImageView>
    with m.SingleTickerProviderStateMixin {
  final double _spinnerSize = 256.0;
  final double _copyrightInset = 16.0;

  final m.ValueNotifier<bool> _buttonBoxActive = m.ValueNotifier(false);
  final m.ValueNotifier<bool> _imageLoaded = m.ValueNotifier(false);

  late final m.AnimationController _fadeInController;
  late final m.Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _fadeInController = m.AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeInAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: _fadeInController,
        curve: m.Curves.easeIn,
      ),
    );

    _imageLoaded.addListener(
      () {
        if (_imageLoaded.value) {
          _fadeInController.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _buttonBoxActive.dispose();
    _imageLoaded.dispose();
    _fadeInController.dispose();
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
            _imageLoaded.value = true;
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
              size: _spinnerSize,
            ),
          ),
        ),
        m.GestureDetector(
          onTap: () {
            if (_imageLoaded.value) {
              _buttonBoxActive.value = !_buttonBoxActive.value;
            }
          },
          child: ii.ImageInteraction(
            mediaMetadata: widget._mediaMetadata,
            showDate: false,
            buttonBoxActive: _buttonBoxActive,
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
                    opacity: _fadeInAnimation,
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
          right: _copyrightInset,
          bottom: _copyrightInset,
          child: m.FadeTransition(
            opacity: _fadeInAnimation,
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

class SingleImageView extends m.StatefulWidget {
  final double? _fillHeightSize;
  final double _headerHeight;
  final mm.MediaMetadata _mediaMetadata;

  @override
  m.State<m.StatefulWidget> createState() => _SingleImageViewState();
  const SingleImageView({
    m.Key? key,
    required double headerHeight,
    required mm.MediaMetadata mediaMetadata,
    double? fillHeightSize,
  })  : _fillHeightSize = fillHeightSize,
        _headerHeight = headerHeight,
        _mediaMetadata = mediaMetadata,
        super(key: key);
}
