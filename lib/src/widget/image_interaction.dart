import 'package:flutter/material.dart' as m;

import '../shared.dart' as s;
import '../media_metadata.dart' as mm;
import 'shared.dart' as ws;
import 'appearance.dart' as a;

class _ImageInteractionState extends m.State<ImageInteraction>
    with m.TickerProviderStateMixin {
  final int _fadeTimeMillis = 500;
  final double _buttonBoxInset = 32.0;
  final double _explanationBoxWidth = 512.0;
  final double _titleScaleFactor = 1.5;
  final double _dateInset = 32.0;

  late final m.AnimationController _buttonBoxFadeController;
  late final m.Animation<double> _buttonBoxFadeAnimation;

  late final m.AnimationController _explanationBackgroundFadeController;
  late final m.Animation<double> _explanationBackgroundFadeAnimation;

  late final m.AnimationController _textFadeController;
  late final m.Animation<double> _textFadeAnimation;

  final m.ValueNotifier<bool> _explanationButtonActive = m.ValueNotifier(false);

  bool _showButtonBox = false;
  bool _showExplanationAndDateText = false;

  @override
  void initState() {
    super.initState();
    _buttonBoxFadeController = m.AnimationController(
      duration: Duration(
        milliseconds: _fadeTimeMillis,
      ),
      vsync: this,
    )..addListener(
        () {
          if (_buttonBoxFadeController.value < 0.01) {
            setState(() {
              _showButtonBox = false;
            });
          } else {
            setState(() {
              _showButtonBox = true;
            });
          }
        },
      );

    _buttonBoxFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: _buttonBoxFadeController,
        curve: m.Curves.easeIn,
      ),
    );

    _explanationBackgroundFadeController = m.AnimationController(
      duration: Duration(
        milliseconds: _fadeTimeMillis,
      ),
      vsync: this,
    )..addListener(
        () {
          if (_explanationBackgroundFadeController.value < 0.01) {
            setState(() {
              _showExplanationAndDateText = false;
            });
          } else {
            setState(() {
              _showExplanationAndDateText = true;
            });
          }
        },
      );

    _explanationBackgroundFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 0.75,
    ).animate(
      m.CurvedAnimation(
        parent: _explanationBackgroundFadeController,
        curve: m.Curves.easeIn,
      ),
    );

    _textFadeController = m.AnimationController(
      duration: Duration(
        milliseconds: _fadeTimeMillis,
      ),
      vsync: this,
    );

    _textFadeAnimation = m.Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      m.CurvedAnimation(
        parent: _textFadeController,
        curve: m.Curves.easeIn,
      ),
    );

    widget._buttonBoxActive.addListener(() {
      if (widget._buttonBoxActive.value) {
        _buttonBoxFadeController.forward(from: _buttonBoxFadeController.value);
      } else {
        _buttonBoxFadeController.reverse(from: _buttonBoxFadeController.value);
      }
      _explanationButtonActive.value = false;
    });

    _explanationButtonActive.addListener(
      () {
        if (_explanationButtonActive.value == true) {
          _explanationBackgroundFadeController.forward(
              from: _explanationBackgroundFadeController.value);
          _textFadeController.forward(
              from: _explanationBackgroundFadeController.value);
        } else {
          _explanationBackgroundFadeController.reverse(
              from: _explanationBackgroundFadeController.value);
          _textFadeController.reverse(from: _textFadeController.value);
        }
      },
    );
  }

  @override
  void dispose() {
    _explanationButtonActive.dispose();
    _textFadeController.dispose();
    _explanationBackgroundFadeController.dispose();
    _buttonBoxFadeController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.Stack(
      children: [
        widget._child,
        if (_showButtonBox)
          m.Positioned(
            top: _buttonBoxInset,
            right: _buttonBoxInset,
            child: m.FadeTransition(
              opacity: _buttonBoxFadeAnimation,
              child: a.buildBox(
                theme: theme,
                child: m.Padding(
                  padding: a.edgeInsets4,
                  child: m.Row(
                    children: [
                      m.MaterialButton(
                        color: _explanationButtonActive.value
                            ? theme.highlightColor
                            : theme.backgroundColor,
                        child: const m.Icon(
                          m.Icons.text_snippet,
                        ),
                        onPressed: () {
                          setState(() {
                            _explanationButtonActive.value =
                                !_explanationButtonActive.value;
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
                                        mediaMetadata:
                                            widget._mediaMetadata)) as ws
                                    .PushArguments)
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
        if (_showExplanationAndDateText)
          m.Positioned.fill(
            child: m.Center(
              child: m.SizedBox(
                width: _explanationBoxWidth,
                child: m.DecoratedBox(
                  decoration: m.BoxDecoration(
                    color: m.Colors.black
                        .withOpacity(_explanationBackgroundFadeAnimation.value),
                    borderRadius: a.boxBorderRadius,
                  ),
                  child: m.FadeTransition(
                    opacity: _textFadeAnimation,
                    child: m.Column(
                      mainAxisSize: m.MainAxisSize.min,
                      children: [
                        m.Padding(
                          padding: a.edgeInsets8,
                          child: m.Text(
                            widget._mediaMetadata.title,
                            textAlign: m.TextAlign.center,
                            textScaleFactor: _titleScaleFactor,
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
        if (widget._showDate && _showExplanationAndDateText)
          m.Positioned(
            left: _dateInset,
            top: _dateInset,
            child: m.FadeTransition(
              opacity: _textFadeAnimation,
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

class ImageInteraction extends m.StatefulWidget {
  final bool _showDate;
  final m.ValueNotifier<bool> _buttonBoxActive;
  final mm.MediaMetadata _mediaMetadata;
  final m.Widget _child;

  @override
  m.State<m.StatefulWidget> createState() => _ImageInteractionState();
  const ImageInteraction({
    m.Key? key,
    required bool showDate,
    required m.ValueNotifier<bool> buttonBoxActive,
    required mm.MediaMetadata mediaMetadata,
    required m.Widget child,
  })  : _showDate = showDate,
        _buttonBoxActive = buttonBoxActive,
        _mediaMetadata = mediaMetadata,
        _child = child,
        super(key: key);
}
