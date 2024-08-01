import 'package:flutter/material.dart' as m;

import '../media_metadata.dart' as mm;
import 'single_image_view.dart' as siv;

class _PageViewSwiperState extends m.State<PageViewSwiper>
    with m.TickerProviderStateMixin {
  final double _navigationButtonSize = 128.0;
  final double _buttonInset = 16.0;
  final Duration _pageTransitionDuration = const Duration(
    milliseconds: 500,
  );

  late final Map<int, mm.MediaMetadata> _mediaMetadataFromIndex;
  late final m.PageController _pageController;

  final m.ValueNotifier<bool> _leftButtonVisible = m.ValueNotifier(true);
  final m.ValueNotifier<bool> _rightButtonVisible = m.ValueNotifier(false);

  late final m.AnimationController _leftButtonFadeController;
  late final m.Animation<double> _leftButtonFadeAnimation;

  late final m.AnimationController _rightButtonFadeController;
  late final m.Animation<double> _rightButtonFadeAnimation;

  int _pageIndex = 0;
  bool _showLeftButton = true;
  bool _showRightButton = false;

  @override
  void initState() {
    super.initState();
    _mediaMetadataFromIndex = widget._mediaMetadataIterable.toList().asMap();
    _pageController = m.PageController(initialPage: _pageIndex);

    _leftButtonFadeController = m.AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _leftButtonFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: _leftButtonFadeController,
        curve: m.Curves.linear,
      ),
    )..addListener(
        () {
          if (_leftButtonFadeAnimation.value < 0.01) {
            setState(
              () {
                _showLeftButton = false;
              },
            );
          } else {
            setState(
              () {
                _showLeftButton = true;
              },
            );
          }
        },
      );

    _rightButtonFadeController = m.AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _rightButtonFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: _rightButtonFadeController,
        curve: m.Curves.linear,
      ),
    )..addListener(
        () {
          if (_rightButtonFadeAnimation.value < 0.01) {
            setState(
              () {
                _showRightButton = false;
              },
            );
          } else {
            setState(() {
              _showRightButton = true;
            });
          }
        },
      );

    _leftButtonVisible.addListener(
      () {
        if (_leftButtonVisible.value) {
          _leftButtonFadeController.forward();
        } else {
          _leftButtonFadeController.reverse();
        }
      },
    );

    _rightButtonVisible.addListener(
      () {
        if (_rightButtonVisible.value) {
          _rightButtonFadeController.forward();
        } else {
          _rightButtonFadeController.reverse();
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
      controller: _pageController,
      allowImplicitScrolling: true,
      onPageChanged: (index) {
        setState(() {
          _pageIndex = index;
        });
      },
      itemBuilder: (context, index) {
        if (_pageIndex == 0) {
          _leftButtonVisible.value = false;
        } else {
          _leftButtonVisible.value = true;
        }

        if (_pageIndex == _mediaMetadataFromIndex.length - 1) {
          _rightButtonVisible.value = false;
        } else {
          _rightButtonVisible.value = true;
        }

        return m.Stack(
          children: [
            siv.SingleImageView(
              fillHeightSize: stackHeight,
              headerHeight: 0.0,
              mediaMetadata: _mediaMetadataFromIndex[index]!,
            ),
            if (_showLeftButton)
              m.Positioned(
                left: _buttonInset,
                top: stackHeight * 0.5 - _navigationButtonSize * 0.5,
                child: m.FadeTransition(
                  opacity: _leftButtonFadeAnimation,
                  child: m.SizedBox(
                    width: _navigationButtonSize,
                    height: _navigationButtonSize,
                    child: m.IconButton(
                      icon: m.Icon(
                        m.Icons.chevron_left,
                        size: _navigationButtonSize * 0.5,
                      ),
                      onPressed: _pageIndex == 0
                          ? null
                          : () {
                              _pageController.previousPage(
                                duration: _pageTransitionDuration,
                                curve: m.Curves.easeIn,
                              );
                            },
                    ),
                  ),
                ),
              ),
            if (_showRightButton)
              m.Positioned(
                right: _buttonInset,
                top: stackHeight * 0.5 - _navigationButtonSize * 0.5,
                child: m.FadeTransition(
                  opacity: _rightButtonFadeAnimation,
                  child: m.SizedBox(
                    width: _navigationButtonSize,
                    height: _navigationButtonSize,
                    child: m.IconButton(
                      icon: m.Icon(
                        m.Icons.chevron_right,
                        size: _navigationButtonSize * 0.5,
                      ),
                      onPressed: index == _mediaMetadataFromIndex.length - 1
                          ? null
                          : () {
                              _pageController.nextPage(
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

class PageViewSwiper extends m.StatefulWidget {
  final Iterable<mm.MediaMetadata> _mediaMetadataIterable;

  @override
  m.State<m.StatefulWidget> createState() => _PageViewSwiperState();

  const PageViewSwiper(
      {super.key, required Iterable<mm.MediaMetadata> mediaMetadataIterable})
      : _mediaMetadataIterable = mediaMetadataIterable;
}
