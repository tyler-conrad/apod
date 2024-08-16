import 'package:flutter/material.dart' as m;

import '../shared.dart' as s;
import '../media_metadata.dart' as mm;
import 'shared.dart' as ws;
import 'appearance.dart' as a;

/// A widget for displaying an image with interaction options.
///
/// The image can be zoomed in, and the explanation and date can be displayed.
class ImageInteraction extends m.StatefulWidget {
  final bool _showDate;
  final m.ValueNotifier<bool> _buttonBoxActive;
  final mm.MediaMetadata _mediaMetadata;
  final m.Widget _child;

  @override
  m.State<m.StatefulWidget> createState() => _ImageInteractionState();
  const ImageInteraction({
    super.key,
    required bool showDate,
    required m.ValueNotifier<bool> buttonBoxActive,
    required mm.MediaMetadata mediaMetadata,
    required m.Widget child,
  })  : _showDate = showDate,
        _buttonBoxActive = buttonBoxActive,
        _mediaMetadata = mediaMetadata,
        _child = child;
}

class _ImageInteractionState extends m.State<ImageInteraction>
    with m.TickerProviderStateMixin {
  final int fadeTimeMillis = 500;
  final double buttonBoxInset = 32.0;
  final double explanationBoxWidth = 512.0;
  final double titleScaleFactor = 1.5;
  final double dateInset = 32.0;

  late final m.AnimationController buttonBoxFadeController;
  late final m.Animation<double> buttonBoxFadeAnimation;

  late final m.AnimationController explanationBackgroundFadeController;
  late final m.Animation<double> explanationBackgroundFadeAnimation;

  late final m.AnimationController textFadeController;
  late final m.Animation<double> textFadeAnimation;

  final m.ValueNotifier<bool> explanationButtonActive = m.ValueNotifier(false);

  bool showButtonBox = false;
  bool showExplanationAndDateText = false;

  @override
  void initState() {
    super.initState();
    buttonBoxFadeController = m.AnimationController(
      duration: Duration(
        milliseconds: fadeTimeMillis,
      ),
      vsync: this,
    )..addListener(
        () {
          if (buttonBoxFadeController.value < 0.01) {
            setState(() {
              showButtonBox = false;
            });
          } else {
            setState(() {
              showButtonBox = true;
            });
          }
        },
      );

    buttonBoxFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: buttonBoxFadeController,
        curve: m.Curves.easeIn,
      ),
    );

    explanationBackgroundFadeController = m.AnimationController(
      duration: Duration(
        milliseconds: fadeTimeMillis,
      ),
      vsync: this,
    )..addListener(
        () {
          if (explanationBackgroundFadeController.value < 0.01) {
            setState(() {
              showExplanationAndDateText = false;
            });
          } else {
            setState(() {
              showExplanationAndDateText = true;
            });
          }
        },
      );

    explanationBackgroundFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 0.75,
    ).animate(
      m.CurvedAnimation(
        parent: explanationBackgroundFadeController,
        curve: m.Curves.easeIn,
      ),
    );

    textFadeController = m.AnimationController(
      duration: Duration(
        milliseconds: fadeTimeMillis,
      ),
      vsync: this,
    );

    textFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: textFadeController,
        curve: m.Curves.easeIn,
      ),
    );

    widget._buttonBoxActive.addListener(() {
      if (widget._buttonBoxActive.value) {
        buttonBoxFadeController.forward(from: buttonBoxFadeController.value);
      } else {
        buttonBoxFadeController.reverse(from: buttonBoxFadeController.value);
      }
      explanationButtonActive.value = false;
    });

    explanationButtonActive.addListener(
      () {
        if (explanationButtonActive.value == true) {
          explanationBackgroundFadeController.forward(
              from: explanationBackgroundFadeController.value);
          textFadeController.forward(
              from: explanationBackgroundFadeController.value);
        } else {
          explanationBackgroundFadeController.reverse(
              from: explanationBackgroundFadeController.value);
          textFadeController.reverse(from: textFadeController.value);
        }
      },
    );
  }

  @override
  void dispose() {
    explanationButtonActive.dispose();
    textFadeController.dispose();
    explanationBackgroundFadeController.dispose();
    buttonBoxFadeController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.Stack(
      children: [
        widget._child,
        if (showButtonBox)
          m.Positioned(
            top: buttonBoxInset,
            right: buttonBoxInset,
            child: m.FadeTransition(
              opacity: buttonBoxFadeAnimation,
              child: a.buildBox(
                theme: theme,
                child: m.Padding(
                  padding: a.edgeInsets4,
                  child: m.Row(
                    children: [
                      m.MaterialButton(
                        color: explanationButtonActive.value
                            ? theme.highlightColor
                            : theme.primaryColor,
                        child: const m.Icon(
                          m.Icons.text_snippet,
                        ),
                        onPressed: () {
                          setState(() {
                            explanationButtonActive.value =
                                !explanationButtonActive.value;
                          });
                        },
                      ),
                      m.MaterialButton(
                        child: const m.Icon(
                          m.Icons.zoom_in,
                        ),
                        onPressed: () async {
                          ws.navigatorKey.currentState?.pushNamed(
                            (await ws.navigatorKey.currentState?.pushNamed(
                                    ws.RouteStringConstants.interactiveViewer,
                                    arguments: ws.PushArguments(
                                      mediaMetadata: widget._mediaMetadata,
                                    )) as ws.PushArguments)
                                .previousRoute!,
                            arguments: ws.PushArguments(
                              mediaMetadata: widget._mediaMetadata,
                              previousRoute: ws.routeHistory[0],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (showExplanationAndDateText)
          m.Positioned.fill(
            child: m.Center(
              child: m.SizedBox(
                width: explanationBoxWidth,
                child: m.DecoratedBox(
                  decoration: m.BoxDecoration(
                    color: m.Colors.black.withOpacity(
                      explanationBackgroundFadeAnimation.value,
                    ),
                    borderRadius: a.boxBorderRadius,
                  ),
                  child: m.FadeTransition(
                    opacity: textFadeAnimation,
                    child: m.Column(
                      mainAxisSize: m.MainAxisSize.min,
                      children: [
                        m.Padding(
                          padding: a.edgeInsets8,
                          child: m.Text(
                            widget._mediaMetadata.title,
                            textAlign: m.TextAlign.center,
                            textScaler: m.TextScaler.linear(titleScaleFactor),
                          ),
                        ),
                        m.Padding(
                          padding: const m.EdgeInsets.fromLTRB(
                            16.0,
                            0.0,
                            16.0,
                            16.0,
                          ),
                          child: m.Text(
                            widget._mediaMetadata.explanation,
                            textAlign: m.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (widget._showDate && showExplanationAndDateText)
          m.Positioned(
            left: dateInset,
            top: dateInset,
            child: m.FadeTransition(
              opacity: textFadeAnimation,
              child: m.Text(
                s.dateStringFromDateTime(
                  dateTime: widget._mediaMetadata.date,
                ),
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
