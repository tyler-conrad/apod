import 'package:flutter/material.dart' as m;

import '../media_metadata.dart' as mm;
import 'single_image_view.dart' as siv;

/// A widget for swiping through a collection of images.
///
/// The user can swipe left and right to navigate through the images and can
/// also use buttons to navigate through the images.
class PageViewSwiper extends m.StatefulWidget {
  final Iterable<mm.MediaMetadata> _mediaMetadataIterable;

  @override
  m.State<m.StatefulWidget> createState() => _PageViewSwiperState();

  const PageViewSwiper(
      {super.key, required Iterable<mm.MediaMetadata> mediaMetadataIterable})
      : _mediaMetadataIterable = mediaMetadataIterable;
}

class _PageViewSwiperState extends m.State<PageViewSwiper>
    with m.TickerProviderStateMixin {
  static const double navigationButtonSize = 128.0;
  static const double buttonInset = 16.0;
  final Duration pageTransitionDuration = const Duration(
    milliseconds: 500,
  );

  late final Map<int, mm.MediaMetadata> mediaMetadataFromIndex;
  late final m.PageController pageController;

  final m.ValueNotifier<bool> leftButtonVisible = m.ValueNotifier(true);
  final m.ValueNotifier<bool> rightButtonVisible = m.ValueNotifier(false);

  late final m.AnimationController leftButtonFadeController;
  late final m.Animation<double> leftButtonFadeAnimation;

  late final m.AnimationController rightButtonFadeController;
  late final m.Animation<double> rightButtonFadeAnimation;

  int pageIndex = 0;
  bool showLeftButton = true;
  bool showRightButton = false;

  @override
  void initState() {
    super.initState();
    mediaMetadataFromIndex = widget._mediaMetadataIterable.toList().asMap();
    pageController = m.PageController(initialPage: pageIndex);

    leftButtonFadeController = m.AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    leftButtonFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: leftButtonFadeController,
        curve: m.Curves.linear,
      ),
    )..addListener(
        () {
          if (leftButtonFadeAnimation.value < 0.01) {
            setState(
              () {
                showLeftButton = false;
              },
            );
          } else {
            setState(
              () {
                showLeftButton = true;
              },
            );
          }
        },
      );

    rightButtonFadeController = m.AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    rightButtonFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: rightButtonFadeController,
        curve: m.Curves.linear,
      ),
    )..addListener(
        () {
          if (rightButtonFadeAnimation.value < 0.01) {
            setState(
              () {
                showRightButton = false;
              },
            );
          } else {
            setState(() {
              showRightButton = true;
            });
          }
        },
      );

    leftButtonVisible.addListener(
      () {
        if (leftButtonVisible.value) {
          leftButtonFadeController.forward();
        } else {
          leftButtonFadeController.reverse();
        }
      },
    );

    rightButtonVisible.addListener(
      () {
        if (rightButtonVisible.value) {
          rightButtonFadeController.forward();
        } else {
          rightButtonFadeController.reverse();
        }
      },
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    var screenSize = m.MediaQuery.of(context).size;
    var appBarHeight = m.Scaffold.of(context).appBarMaxHeight!.toDouble();
    var stackHeight = screenSize.height - appBarHeight;
    return m.PageView.builder(
      controller: pageController,
      allowImplicitScrolling: true,
      onPageChanged: (index) {
        setState(() {
          pageIndex = index;
        });
      },
      itemBuilder: (context, index) {
        if (pageIndex == 0) {
          leftButtonVisible.value = false;
        } else {
          leftButtonVisible.value = true;
        }

        if (pageIndex == mediaMetadataFromIndex.length - 1) {
          rightButtonVisible.value = false;
        } else {
          rightButtonVisible.value = true;
        }

        return m.Stack(
          children: [
            siv.SingleImageView(
              fillHeightSize: stackHeight,
              headerHeight: 0.0,
              mediaMetadata: mediaMetadataFromIndex[index]!,
            ),
            if (showLeftButton)
              m.Positioned(
                left: buttonInset,
                top: stackHeight * 0.5 - navigationButtonSize * 0.5,
                child: m.FadeTransition(
                  opacity: leftButtonFadeAnimation,
                  child: m.SizedBox(
                    width: navigationButtonSize,
                    height: navigationButtonSize,
                    child: m.IconButton(
                      icon: const m.Icon(
                        m.Icons.chevron_left,
                        size: navigationButtonSize * 0.5,
                      ),
                      onPressed: pageIndex == 0
                          ? null
                          : () {
                              pageController.previousPage(
                                duration: pageTransitionDuration,
                                curve: m.Curves.easeIn,
                              );
                            },
                    ),
                  ),
                ),
              ),
            if (showRightButton)
              m.Positioned(
                right: buttonInset,
                top: stackHeight * 0.5 - navigationButtonSize * 0.5,
                child: m.FadeTransition(
                  opacity: rightButtonFadeAnimation,
                  child: m.SizedBox(
                    width: navigationButtonSize,
                    height: navigationButtonSize,
                    child: m.IconButton(
                      icon: const m.Icon(
                        m.Icons.chevron_right,
                        size: navigationButtonSize * 0.5,
                      ),
                      onPressed: index == mediaMetadataFromIndex.length - 1
                          ? null
                          : () {
                              pageController.nextPage(
                                duration: const Duration(
                                  milliseconds: 500,
                                ),
                                curve: m.Curves.easeIn,
                              );
                            },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
