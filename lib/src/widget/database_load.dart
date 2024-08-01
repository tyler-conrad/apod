import 'package:flutter/material.dart' as m;

import 'shared.dart' as ws;
import 'appearance.dart' as a;

class _DatabaseLoadState extends m.State<DatabaseLoad> {
  final m.ValueNotifier<double> _progressNotifier =
      m.ValueNotifier<double>(0.0);
  bool _firstPress = true;

  void onPressed() {
    if (_firstPress) {
      setState(() {
        _firstPress = false;
      });
      widget._progress.listen((progress) {
        _progressNotifier.value = progress;
      }, onDone: () {
        ws.navigatorKey.currentState?.pushNamed(
          ws.RouteStringConstants.home,
        );
      });
    }
  }

  @override
  void dispose() {
    _progressNotifier.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    var theme = m.Theme.of(context);
    return m.SizedBox(
      width: 400,
      child: a.buildBox(
        theme: theme,
        child: m.Column(
          mainAxisSize: m.MainAxisSize.min,
          mainAxisAlignment: m.MainAxisAlignment.center,
          children: [
            m.Padding(
              padding: a.edgeInsets8,
              child: m.Text(
                widget._message,
                textAlign: m.TextAlign.center,
              ),
            ),
            m.Padding(
              padding: const m.EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
              child: m.MaterialButton(
                shape: m.RoundedRectangleBorder(
                  borderRadius: a.boxBorderRadius,
                ),
                color: _firstPress ? theme.primaryColor : theme.highlightColor,
                onPressed: onPressed,
                child: m.Text(
                  widget._buttonText,
                  textAlign: m.TextAlign.center,
                ),
              ),
            ),
            m.Padding(
              padding: a.edgeInsets16,
              child: m.ValueListenableBuilder(
                valueListenable: _progressNotifier,
                builder: (
                  context,
                  double loadProgress,
                  child,
                ) {
                  return m.LinearProgressIndicator(
                    color: theme.primaryColorDark,
                    backgroundColor: theme.highlightColor,
                    value: loadProgress,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseLoad extends m.StatefulWidget {
  final String _message;
  final String _buttonText;
  final Stream<double> _progress;

  @override
  m.State<m.StatefulWidget> createState() => _DatabaseLoadState();

  const DatabaseLoad({
    super.key,
    required String message,
    required String buttonText,
    required Stream<double> progress,
  })  : _message = message,
        _buttonText = buttonText,
        _progress = progress;
}
