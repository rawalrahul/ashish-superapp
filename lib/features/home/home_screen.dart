import 'package:flutter/material.dart';

import '../../constants/ai_apps.dart';
import '../../data/stats_repository.dart';

/// Dashboard: totals plus per-app and per-day breakdowns, all derived from the
/// event log via [StatsRepository].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.stats});

  final StatsRepository stats;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Stats> _future = widget.stats.load();

  Future<void> _refresh() async {
    final next = widget.stats.load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<Stats>(
        future: _future,
        builder: (context, snapshot) {
          final stats = snapshot.data ?? Stats.empty;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Your reflections', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(label: 'Pauses', value: stats.totalOpens),
                  _StatCard(label: 'Reflections', value: stats.typedAttempts),
                  _StatCard(label: 'Backed out', value: stats.backedOut),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatCard(label: 'Waited', value: stats.proceededAfterWait),
                  _StatCard(label: 'Skipped', value: stats.skipped),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 24),
              _Breakdown(
                title: 'By app',
                entries: {
                  for (final e in stats.perApp.entries)
                    displayNameForPackage(e.key): e.value,
                },
              ),
              const SizedBox(height: 24),
              _Breakdown(title: 'By day', entries: stats.perDay),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text('$value', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.title, required this.entries});

  final String title;
  final Map<String, int> entries;

  @override
  Widget build(BuildContext context) {
    final sorted = entries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (sorted.isEmpty)
          const Text('No data yet.')
        else
          ...sorted.map(
            (e) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(e.key),
              trailing: Text('${e.value}'),
            ),
          ),
      ],
    );
  }
}
