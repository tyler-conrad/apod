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

/// Contains a foreground and background image for the slide show.
///
/// Used with a [m.ValueNotifier] to update the foreground and background images
/// in the slide show.
class SlideShowImageForegroundAndBackground {
  final m.FadeInImage foreground;
  final m.FadeInImage? background;

  SlideShowImageForegroundAndBackground({
    required this.foreground,
    this.background,
  });
}

/// A slide show widget that displays images from the NASA APOD API.
///
/// The slide show displays images with a fade-in animation. The foreground and
/// background image are displayed with a scale animation.
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

class _SlideShowState extends m.State<SlideShow>
    with m.TickerProviderStateMixin {
  final Duration imageScaleDuration = const Duration(
    seconds: 10,
  );
  static const double dateIconSize = 256.0;
  static const double copyrightInset = 16.0;

  late final m.AnimationController foregroundScaleController;
  late final m.Animation<double> foregroundScaleAnimation;

  late final m.AnimationController backgroundScaleController;
  late final m.Animation<double> backgroundScaleAnimation;

  late final m.AnimationController copyrightFadeController;
  late final m.Animation<double> copyrightFadeAnimation;

  final Iterator<mm.MediaMetadata> randomImageIterator =
      c.controller.randomImage().iterator;

  late final m.ValueNotifier<SlideShowImageForegroundAndBackground>
      foregroundAndBackground;

  final m.ValueNotifier<String> imageCopyright = m.ValueNotifier<String>(
    '',
  );

  final m.ValueNotifier<bool> animating = m.ValueNotifier<bool>(
    true,
  );

  final m.ValueNotifier<bool> buttonBoxActive = m.ValueNotifier(
    false,
  );

  late final m.Widget foreground;

  late mm.MediaMetadata currentMetadata;

  bool placeholderImageComplete = false;

  @override
  void initState() {
    super.initState();

    randomImageIterator.moveNext();
    currentMetadata = randomImageIterator.current;
    final String nextImageUrl = randomImageIterator.current.hdUrl!;

    imageCopyright.value = '';

    foregroundAndBackground =
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
                      placeholderImageComplete = true;
                    },
                  );
                }
              },
            ),
          ),
        background: null,
      ),
    );

    foregroundScaleController = m.AnimationController(
      duration: imageScaleDuration,
      vsync: this,
    );

    foregroundScaleAnimation = m.Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      m.CurvedAnimation(
        parent: foregroundScaleController,
        curve: m.Curves.easeIn,
      ),
    );

    foregroundScaleController.addStatusListener((status) {
      if (status == m.AnimationStatus.completed) {
        randomImageIterator.moveNext();
        setState(() {
          currentMetadata = randomImageIterator.current;
        });
        foregroundAndBackground.value = SlideShowImageForegroundAndBackground(
            foreground: ws.buildWidgetFillFadeInImage(
              placeholder: t.kTransparentImage,
              image: currentMetadata.hdUrl!,
            ),
            background: foregroundAndBackground.value.foreground);
        imageCopyright.value = currentMetadata.copyrightWithSymbol;
        foregroundScaleController.reset();
        foregroundScaleController.forward();
      }
    });

    foregroundScaleController.forward();

    backgroundScaleController = m.AnimationController(
      duration: imageScaleDuration,
      vsync: this,
    );

    backgroundScaleAnimation = m.Tween<double>(
      begin: 1.1,
      end: 1.2,
    ).animate(
      m.CurvedAnimation(
        parent: backgroundScaleController,
        curve: m.Curves.linear,
      ),
    );

    backgroundScaleController.addStatusListener(
      (status) {
        if (status == m.AnimationStatus.completed) {
          backgroundScaleController.reset();
          backgroundScaleController.forward();
        }
      },
    );

    backgroundScaleController.forward();

    copyrightFadeController = m.AnimationController(
      duration: const Duration(
        seconds: 5,
      ),
      vsync: this,
    );
    copyrightFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: copyrightFadeController,
        curve: m.Curves.easeIn,
      ),
    );
    copyrightFadeController.addStatusListener(
      (status) {
        if (status == m.AnimationStatus.completed) {
          copyrightFadeController.reverse();
        }
        if (status == m.AnimationStatus.dismissed) {
          copyrightFadeController.reset();
          copyrightFadeController.forward();
        }
      },
    );
    copyrightFadeController.forward();

    foreground = m.ScaleTransition(
      scale: foregroundScaleAnimation,
      child: m.ValueListenableBuilder<SlideShowImageForegroundAndBackground>(
        valueListenable: foregroundAndBackground,
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
    buttonBoxActive.dispose();
    animating.dispose();
    imageCopyright.dispose();
    foregroundAndBackground.dispose();
    copyrightFadeController.dispose();
    backgroundScaleController.dispose();
    foregroundScaleController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.GestureDetector(
      onTap: () {
        if (widget._homeScreenMenu == null) {
          if (animating.value) {
            animating.value = false;
            buttonBoxActive.value =
                placeholderImageComplete == true ? true : false;
            foregroundScaleController.stop();
            backgroundScaleController.stop();
            copyrightFadeController.stop();
          } else {
            animating.value = true;
            buttonBoxActive.value = false;
            foregroundScaleController.forward();
            backgroundScaleController.forward();
            copyrightFadeController.forward();
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
            scale: backgroundScaleAnimation,
            child:
                m.ValueListenableBuilder<SlideShowImageForegroundAndBackground>(
              valueListenable: foregroundAndBackground,
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
                  width: dateIconSize,
                  height: dateIconSize,
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
                        child: const m.Icon(
                          m.Icons.calendar_today,
                          size: dateIconSize * 0.5,
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
              buttonBoxActive: buttonBoxActive,
              mediaMetadata: currentMetadata,
              child: foreground,
            ),
          m.ValueListenableBuilder<String>(
            valueListenable: imageCopyright,
            builder: (
              m.BuildContext context,
              String copyright,
              m.Widget? child,
            ) {
              return m.Positioned(
                right: copyrightInset,
                bottom: copyrightInset,
                child: m.FadeTransition(
                  opacity: copyrightFadeAnimation,
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
