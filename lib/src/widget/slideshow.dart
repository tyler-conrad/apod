import 'package:flutter/material.dart' as m;
import 'package:timezone/timezone.dart' as tz;
import 'package:transparent_image/transparent_image.dart' as t;

import '../shared.dart' as s;
import '../media_metadata.dart' as mm;
import '../controller.dart' as c;
import 'shared.dart' as ws;
import 'appearance.dart' as a;
import 'image_interaction.dart' as ii;
import 'home_screen.dart' as hs;

class SlideShowImageForegroundAndBackground {
  final m.FadeInImage foreground;
  final m.FadeInImage? background;

  SlideShowImageForegroundAndBackground({
    required this.foreground,
    this.background,
  });
}

class _SlideShowState extends m.State<SlideShow>
    with m.TickerProviderStateMixin {
  final Duration _imageScaleDuration = const Duration(
    seconds: 10,
  );
  final double _dateIconSize = 256.0;
  final double _copyrightInset = 16.0;

  late final m.AnimationController _foregroundScaleController;
  late final m.Animation<double> _foregroundScaleAnimation;

  late final m.AnimationController _backgroundScaleController;
  late final m.Animation<double> _backgroundScaleAnimation;

  late final m.AnimationController _copyrightFadeController;
  late final m.Animation<double> _copyrightFadeAnimation;

  final Iterator<mm.MediaMetadata> _randomImageIterator =
      c.controller.randomImage().iterator;

  late final m.ValueNotifier<SlideShowImageForegroundAndBackground>
      _foregroundAndBackground;

  final m.ValueNotifier<String> _imageCopyright = m.ValueNotifier<String>(
    '',
  );

  final m.ValueNotifier<bool> _animating = m.ValueNotifier<bool>(
    true,
  );

  final m.ValueNotifier<bool> _buttonBoxActive = m.ValueNotifier(
    false,
  );

  late final m.Widget _foreground;

  late mm.MediaMetadata currentMetadata;

  bool _placeholderImageComplete = false;

  @override
  void initState() {
    super.initState();

    _randomImageIterator.moveNext();
    currentMetadata = _randomImageIterator.current;
    final String nextImageUrl = _randomImageIterator.current.hdUrl!;

    _imageCopyright.value = '';

    _foregroundAndBackground =
        m.ValueNotifier<SlideShowImageForegroundAndBackground>(
      SlideShowImageForegroundAndBackground(
        foreground: ws.buildWidgetFillFadeInImage(
          placeholder: t.kTransparentImage,
          image: nextImageUrl,
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
                      _placeholderImageComplete = true;
                    },
                  );
                }
              },
            ),
          ),
        background: null,
      ),
    );

    _foregroundScaleController = m.AnimationController(
      duration: _imageScaleDuration,
      vsync: this,
    );

    _foregroundScaleAnimation = m.Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      m.CurvedAnimation(
        parent: _foregroundScaleController,
        curve: m.Curves.easeIn,
      ),
    );

    _foregroundScaleController.addStatusListener((status) {
      if (status == m.AnimationStatus.completed) {
        _randomImageIterator.moveNext();
        setState(() {
          currentMetadata = _randomImageIterator.current;
        });
        _foregroundAndBackground.value = SlideShowImageForegroundAndBackground(
            foreground: ws.buildWidgetFillFadeInImage(
              placeholder: t.kTransparentImage,
              image: currentMetadata.hdUrl!,
            ),
            background: _foregroundAndBackground.value.foreground);
        _imageCopyright.value = currentMetadata.copyrightWithSymbol;
        _foregroundScaleController.reset();
        _foregroundScaleController.forward();
      }
    });

    _foregroundScaleController.forward();

    _backgroundScaleController = m.AnimationController(
      duration: _imageScaleDuration,
      vsync: this,
    );

    _backgroundScaleAnimation = m.Tween<double>(
      begin: 1.1,
      end: 1.2,
    ).animate(
      m.CurvedAnimation(
        parent: _backgroundScaleController,
        curve: m.Curves.linear,
      ),
    );

    _backgroundScaleController.addStatusListener(
      (status) {
        if (status == m.AnimationStatus.completed) {
          _backgroundScaleController.reset();
          _backgroundScaleController.forward();
        }
      },
    );

    _backgroundScaleController.forward();

    _copyrightFadeController = m.AnimationController(
      duration: const Duration(
        seconds: 5,
      ),
      vsync: this,
    );
    _copyrightFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: _copyrightFadeController,
        curve: m.Curves.easeIn,
      ),
    );
    _copyrightFadeController.addStatusListener(
      (status) {
        if (status == m.AnimationStatus.completed) {
          _copyrightFadeController.reverse();
        }
        if (status == m.AnimationStatus.dismissed) {
          _copyrightFadeController.reset();
          _copyrightFadeController.forward();
        }
      },
    );
    _copyrightFadeController.forward();

    _foreground = m.ScaleTransition(
      scale: _foregroundScaleAnimation,
      child: m.ValueListenableBuilder<SlideShowImageForegroundAndBackground>(
        valueListenable: _foregroundAndBackground,
        builder: (
          m.BuildContext context,
          SlideShowImageForegroundAndBackground ssifgab,
          m.Widget? child,
        ) {
          return ssifgab.foreground;
        },
      ),
    );
  }

  @override
  void dispose() {
    _buttonBoxActive.dispose();
    _animating.dispose();
    _imageCopyright.dispose();
    _foregroundAndBackground.dispose();
    _copyrightFadeController.dispose();
    _backgroundScaleController.dispose();
    _foregroundScaleController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.GestureDetector(
      onTap: () {
        if (widget._homeScreenMenu == null) {
          if (_animating.value) {
            _animating.value = false;
            _buttonBoxActive.value =
                _placeholderImageComplete == true ? true : false;
            _foregroundScaleController.stop();
            _backgroundScaleController.stop();
            _copyrightFadeController.stop();
          } else {
            _animating.value = true;
            _buttonBoxActive.value = false;
            _foregroundScaleController.forward();
            _backgroundScaleController.forward();
            _copyrightFadeController.forward();
          }
        }
      },
      child: m.Stack(
        children: [
          m.Positioned.fill(
            child: m.DecoratedBox(
              decoration: m.BoxDecoration(
                color: theme.primaryColor,
              ),
            ),
          ),
          m.ScaleTransition(
            scale: _backgroundScaleAnimation,
            child:
                m.ValueListenableBuilder<SlideShowImageForegroundAndBackground>(
              valueListenable: _foregroundAndBackground,
              builder: (
                m.BuildContext context,
                SlideShowImageForegroundAndBackground ssifgab,
                m.Widget? child,
              ) {
                return ssifgab.background == null
                    ? ws.placeholder
                    : ssifgab.background!;
              },
            ),
          ),
          if (widget._lookupByDateMode)
            m.Positioned.fill(
              child: m.Center(
                child: m.SizedBox(
                  width: _dateIconSize,
                  height: _dateIconSize,
                  child: a.buildBox(
                    theme: theme,
                    child: m.Padding(
                      padding: a.edgeInsets16,
                      child: m.MaterialButton(
                        onPressed: () async {
                          var pickedDateTime = await m.showDatePicker(
                            context: context,
                            initialDate: c.earliestMediaMetadata,
                            firstDate: c.earliestMediaMetadata,
                            lastDate: s.timeZoneNow(),
                            currentDate: s.timeZoneNow(),
                          );
                          if (pickedDateTime != null) {
                            ws.navigatorKey.currentState?.pushNamed(
                              ws.RouteStringConstants.singleImageView,
                              arguments: ws.PushArguments(
                                mediaMetadata: c.controller.fromDateTime(
                                  dateTime: tz.TZDateTime.from(
                                    pickedDateTime,
                                    s.timeZone,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: m.Icon(
                          m.Icons.calendar_today,
                          size: _dateIconSize * 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (widget._homeScreenMenu == null && !widget._lookupByDateMode)
            ii.ImageInteraction(
              showDate: true,
              buttonBoxActive: _buttonBoxActive,
              mediaMetadata: currentMetadata,
              child: _foreground,
            ),
          m.ValueListenableBuilder<String>(
            valueListenable: _imageCopyright,
            builder: (
              m.BuildContext context,
              String copyright,
              m.Widget? child,
            ) {
              return m.Positioned(
                right: _copyrightInset,
                bottom: _copyrightInset,
                child: m.FadeTransition(
                  opacity: _copyrightFadeAnimation,
                  child: m.Text(
                    copyright,
                  ),
                ),
              );
            },
          ),
          if (widget._homeScreenMenu != null) widget._homeScreenMenu!,
        ],
      ),
    );
  }
}

class SlideShow extends m.StatefulWidget {
  final bool _lookupByDateMode;
  final hs.HomeScreenMenu? _homeScreenMenu;

  @override
  m.State<m.StatefulWidget> createState() => _SlideShowState();

  const SlideShow(
      {super.key,
      required bool lookupByDateMode,
      hs.HomeScreenMenu? homeScreenMenu})
      : _lookupByDateMode = lookupByDateMode,
        _homeScreenMenu = homeScreenMenu;
}
