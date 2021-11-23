import 'package:flutter/material.dart' as m;

import '../shared.dart' as s;
import '../controller.dart' as c;
import 'database_load.dart' as dl;
import 'shared.dart' as ws;

enum PopulateDatabasePageStrategy {
  uninitialized,
  needsInitialLoad,
  needsUpdate,
  populated
}

class _PopulateDatabasePageState extends m.State<PopulateDatabasePage> {
  final m.ValueNotifier<PopulateDatabasePageStrategy> populationStrategy =
      m.ValueNotifier<PopulateDatabasePageStrategy>(
          PopulateDatabasePageStrategy.uninitialized);

  @override
  void initState() {
    super.initState();
    populationStrategy.addListener(() {
      if (populationStrategy.value == PopulateDatabasePageStrategy.populated) {
        ws.navigatorKey.currentState?.pushNamed(
          ws.RouteStringConstants.home,
        );
      }
    });
  }

  Future<PopulateDatabasePageStrategy> getStrategy() async {
    switch (await c.controller.databasePopulationStrategy()) {
      case c.DatabasePopulationStrategy.needsInitialLoad:
        return PopulateDatabasePageStrategy.needsInitialLoad;
      case c.DatabasePopulationStrategy.needsUpdate:
        return PopulateDatabasePageStrategy.needsUpdate;
      case c.DatabasePopulationStrategy.populated:
        return PopulateDatabasePageStrategy.populated;
    }
  }

  @override
  void dispose() {
    populationStrategy.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    return m.ValueListenableBuilder<PopulateDatabasePageStrategy>(
      valueListenable: populationStrategy,
      builder: (m.BuildContext _context,
          PopulateDatabasePageStrategy populationStrategy, m.Widget? _child) {
        return m.Stack(
          children: [
            s.nasaLogo,
            if (populationStrategy ==
                PopulateDatabasePageStrategy.needsInitialLoad)
              m.Center(
                child: dl.DatabaseLoad(
                  message:
                      'A database of images needs to be populated in order to satisfy rate limits for the API.  This is a one time operation that may take a few minutes, subsequent uses of the App will only download images that have been newly added.',
                  buttonText: 'Populate',
                  progress: c.controller.populateDatabase(),
                ),
              ),
            if (populationStrategy == PopulateDatabasePageStrategy.needsUpdate)
              m.Center(
                child: dl.DatabaseLoad(
                  message: 'The database of images needs to be updated.',
                  buttonText: 'Update',
                  progress: c.controller.updateDatabase(),
                ),
              ),
          ],
        );
      },
    );
  }

  _PopulateDatabasePageState() {
    Future.delayed(const Duration(seconds: 1)).then((_) {
      getStrategy().then((strategy) {
        populationStrategy.value = strategy;
      });
    });
  }
}

class PopulateDatabasePage extends m.StatefulWidget {
  @override
  m.State<PopulateDatabasePage> createState() => _PopulateDatabasePageState();

  const PopulateDatabasePage({m.Key? key}) : super(key: key);
}
