import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../constants/ai_apps.dart';
import '../../data/settings_store.dart';
import '../../services/native_bridge.dart';

/// Pick watched apps, tune the delay/grace, edit prompts, and grant the
/// required system permissions.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.bridge,
  });

  final SettingsStore settings;
  final NativeBridge bridge;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late List<String> _watched = widget.settings.watchedPackages;
  late int _delay = widget.settings.delaySeconds;
  late int _grace = widget.settings.graceMinutes;
  late bool _requireText = widget.settings.requireTextBeforeContinue;

  Set<String> _installed = {};
  bool _a11yEnabled = false;

  /// Interception is Android-only in v1 (see plan.md). iOS renders settings +
  /// stats but the interception section is a placeholder.
  bool get _interceptionSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (_interceptionSupported) _refreshNativeState();
  }

  Future<void> _refreshNativeState() async {
    try {
      final installed = await widget.bridge
          .queryInstalledAiApps(kCuratedAiApps.map((a) => a.packageName).toList());
      final enabled = await widget.bridge.isA11yEnabled();
      if (!mounted) return;
      setState(() {
        _installed = installed.toSet();
        _a11yEnabled = enabled;
      });
    } catch (_) {
      // Native side unavailable (e.g. running the normal-app preview on host).
    }
  }

  Future<void> _toggleWatched(String pkg, bool on) async {
    setState(() {
      _watched = [..._watched]..remove(pkg);
      if (on) _watched.add(pkg);
    });
    await widget.settings.setWatchedPackages(_watched);
  }

  @override
  Widget build(BuildContext context) {
    if (!_interceptionSupported) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.hourglass_empty),
              title: Text('Interception coming in v2'),
              subtitle: Text(
                'Pausing AI apps is available on Android today. iOS support is '
                'planned for a future version.',
              ),
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PermissionCard(
          enabled: _a11yEnabled,
          onEnableA11y: () async {
            try {
              await widget.bridge.openA11ySettings();
            } catch (_) {/* native unavailable */}
          },
          onGrantOverlay: () async {
            try {
              await widget.bridge.openOverlaySettings();
            } catch (_) {/* native unavailable */}
          },
          onRefresh: _refreshNativeState,
        ),
        const SizedBox(height: 16),
        Text('Watched apps', style: Theme.of(context).textTheme.titleMedium),
        ...kCuratedAiApps.map((app) {
          final installed = _installed.contains(app.packageName);
          return SwitchListTile(
            title: Text(app.name),
            subtitle: Text(installed ? app.packageName : '${app.packageName} (not installed)'),
            value: _watched.contains(app.packageName),
            onChanged: (v) => _toggleWatched(app.packageName, v),
          );
        }),
        const Divider(height: 32),
        Text('Pause delay: $_delay s',
            style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _delay.toDouble(),
          min: 0,
          max: 60,
          divisions: 60,
          label: '$_delay s',
          onChanged: (v) => setState(() => _delay = v.round()),
          onChangeEnd: (v) => widget.settings.setDelaySeconds(v.round()),
        ),
        Text('Grace window: $_grace min',
            style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _grace.toDouble(),
          min: 0,
          max: 60,
          divisions: 60,
          label: '$_grace min',
          onChanged: (v) => setState(() => _grace = v.round()),
          onChangeEnd: (v) => widget.settings.setGraceMinutes(v.round()),
        ),
        SwitchListTile(
          title: const Text('Require a reflection before continuing'),
          value: _requireText,
          onChanged: (v) {
            setState(() => _requireText = v);
            widget.settings.setRequireTextBeforeContinue(v);
          },
        ),
        const Divider(height: 32),
        ListTile(
          title: const Text('Edit prompts'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _editPrompts(context),
        ),
      ],
    );
  }

  Future<void> _editPrompts(BuildContext context) async {
    final prompts = await widget.settings.effectivePrompts();
    if (!context.mounted) return;
    final controller = TextEditingController(text: prompts.join('\n'));
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prompts (one per line)'),
        content: TextField(
          controller: controller,
          maxLines: 12,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true) {
      final lines = controller.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      await widget.settings.setPrompts(lines);
    }
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.enabled,
    required this.onEnableA11y,
    required this.onGrantOverlay,
    required this.onRefresh,
  });

  final bool enabled;
  final VoidCallback onEnableA11y;
  final VoidCallback onGrantOverlay;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(enabled ? Icons.check_circle : Icons.error_outline,
                    color: enabled ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                Text(enabled
                    ? 'Accessibility service enabled'
                    : 'Accessibility service off'),
                const Spacer(),
                IconButton(
                    onPressed: onRefresh, icon: const Icon(Icons.refresh)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                    onPressed: onEnableA11y,
                    child: const Text('Enable service')),
                OutlinedButton(
                    onPressed: onGrantOverlay,
                    child: const Text('Allow over other apps')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
