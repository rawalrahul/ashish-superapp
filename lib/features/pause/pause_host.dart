import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/ai_apps.dart';
import '../../data/database.dart';
import '../../data/event_repository.dart';
import '../../data/settings_store.dart';
import '../../services/intercept_channel.dart';
import 'pause_screen.dart';

/// Entry widget for the cached pause engine. Loads the target app + settings,
/// shows [PauseScreen], records the outcome, and dismisses the Activity.
class PauseHost extends StatefulWidget {
  const PauseHost({super.key, this.interceptChannel});

  final InterceptChannel? interceptChannel;

  @override
  State<PauseHost> createState() => _PauseHostState();
}

class _PauseHostState extends State<PauseHost> {
  late final InterceptChannel _intercept =
      widget.interceptChannel ?? InterceptChannel();

  String? _packageName;
  String _prompt = '';
  int _delaySeconds = SettingsStore.defaultDelaySeconds;
  bool _requireText = false;

  SettingsStore? _settings;
  EventRepository? _events;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsStore(prefs);
    final db = AppDatabase(openAppDatabaseConnection());

    final target = await _intercept.getTarget();
    final prompt = await settings.nextPrompt();

    if (!mounted) return;
    setState(() {
      _packageName = target;
      _prompt = prompt;
      _delaySeconds = settings.delaySeconds;
      _requireText = settings.requireTextBeforeContinue;
      _settings = settings;
      _events = EventRepository(db);
      _ready = true;
    });
  }

  Future<void> _onResolved(PauseResult result) async {
    final pkg = _packageName ?? 'unknown';
    await _events?.record(
      packageName: pkg,
      outcome: result.outcome,
      typedAttempt: result.typedAttempt,
      attemptText: result.attemptText,
      waitedSeconds: result.waitedSeconds,
    );

    final backedOut = result.outcome == InterceptOutcome.backedOut;
    if (!backedOut) {
      await _settings?.markAllowed(pkg);
    }
    await _intercept.exit(goHome: backedOut);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: !_ready
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : PauseScreen(
              appName: displayNameForPackage(_packageName ?? ''),
              prompt: _prompt,
              delaySeconds: _delaySeconds,
              requireText: _requireText,
              onResolved: _onResolved,
            ),
    );
  }
}
