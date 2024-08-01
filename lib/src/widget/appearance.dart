import 'package:flutter/material.dart' as m;

List<m.Shadow> shadows() {
  return List.generate(
    4,
    (index) => const m.Shadow(
      blurRadius: 4.0,
      color: m.Color.fromARGB(255, 0, 0, 0),
    ),
  );
}

List<m.BoxShadow> boxShadows() {
  return List.generate(
    4,
    (_) => const m.BoxShadow(
      blurRadius: 16.0,
      color: m.Color.fromARGB(255, 0, 0, 0),
    ),
  );
}

m.BorderRadius boxBorderRadius = const m.BorderRadius.all(
  m.Radius.circular(
    8.0,
  ),
);

m.EdgeInsets edgeInsets4 = const m.EdgeInsets.all(
  4.0,
);

m.EdgeInsets edgeInsets8 = const m.EdgeInsets.all(
  8.0,
);

m.EdgeInsets edgeInsets16 = const m.EdgeInsets.all(
  16.0,
);

m.EdgeInsets edgeInsets24 = const m.EdgeInsets.all(
  24.0,
);

m.DecoratedBox buildBox({required m.ThemeData theme, required m.Widget child}) {
  return m.DecoratedBox(
    decoration: m.BoxDecoration(
      color: theme.primaryColor,
      borderRadius: boxBorderRadius,
      boxShadow: boxShadows(),
    ),
    child: child,
  );
}
