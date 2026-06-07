import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'data/settings_store.dart';
import 'data/stats_repository.dart';
import 'features/home/home_screen.dart';
import 'features/pause/pause_host.dart';
import 'features/settings/settings_screen.dart';
import 'services/native_bridge.dart';

/// Normal app launch (home + settings).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase(openAppDatabaseConnection());
  runApp(PauseReflectApp(
    settings: SettingsStore(prefs),
    stats: StatsRepository(db),
    bridge: NativeBridge(),
  ));
}

/// Cached-engine entrypoint, pre-warmed by `PauseApplication` and driven by
/// `InterceptActivity`. Kept separate from [main] so the pause screen can launch
/// instantly without booting the whole app shell.
@pragma('vm:entry-point')
void pauseMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PauseHost());
}

class PauseReflectApp extends StatelessWidget {
  const PauseReflectApp({
    super.key,
    required this.settings,
    required this.stats,
    required this.bridge,
  });

  final SettingsStore settings;
  final StatsRepository stats;
  final NativeBridge bridge;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pause & Reflect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: HomeShell(settings: settings, stats: stats, bridge: bridge),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.settings,
    required this.stats,
    required this.bridge,
  });

  final SettingsStore settings;
  final StatsRepository stats;
  final NativeBridge bridge;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(stats: widget.stats),
      SettingsScreen(settings: widget.settings, bridge: widget.bridge),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Pause & Reflect' : 'Settings'),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.insights), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
