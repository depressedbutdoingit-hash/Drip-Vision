import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../services/continuity_health_analyzer.dart';
import '../../services/continuity_service.dart';

/// CONTINUITY HEALTH — make memory visible.
class ContinuityHealthScreen extends ConsumerWidget {
  const ContinuityHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(characterListProvider);
    final scenes = ref.watch(sceneListProvider);
    final report = ContinuityHealthAnalyzer().analyze(
      characters: characters,
      scenes: scenes,
    );

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('CONTINUITY', style: DripTheme.brandMark),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          const Text('HEALTH', style: DripTheme.overline),
          const SizedBox(height: 10),
          Text(
            'The film never forgets.',
            style: DripTheme.meta,
          ),
          const SizedBox(height: 20),
          _OverallCard(score: report.overallScore, issueCount: report.issues.length),
          const SizedBox(height: 28),
          const Text('CAST', style: DripTheme.overline),
          const SizedBox(height: 12),
          ...report.characterMetrics.map((m) => _MetricTile(m)),
          const SizedBox(height: 24),
          const Text('LOCATIONS', style: DripTheme.overline),
          const SizedBox(height: 12),
          ...report.locationMetrics.map((m) => _MetricTile(m)),
          const SizedBox(height: 24),
          const Text('STORY', style: DripTheme.overline),
          const SizedBox(height: 12),
          ...report.storyMetrics.map((m) => _MetricTile(m)),
          const SizedBox(height: 24),
          const Text('ISSUES', style: DripTheme.overline),
          const SizedBox(height: 12),
          if (report.issues.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DripTheme.surface,
                borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                border: Border.all(color: DripTheme.hairline),
              ),
              child: const Text(
                'No continuity conflicts detected.',
                style: DripTheme.meta,
              ),
            )
          else
            ...report.issues.map((i) => _IssueTile(issue: i)),
        ],
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  final int score;
  final int issueCount;
  const _OverallCard({required this.score, required this.issueCount});

  @override
  Widget build(BuildContext context) {
    final tone = score >= 90
        ? HealthTone.good
        : score >= 70
            ? HealthTone.warn
            : score <= 0
                ? HealthTone.idle
                : HealthTone.bad;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DripTheme.surface,
        borderRadius: BorderRadius.circular(DripTheme.radiusMd),
        border: Border.all(color: DripTheme.hairlineStrong),
      ),
      child: Row(
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w300,
              letterSpacing: -1,
              color: _toneColor(tone),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CONTINUITY SCORE', style: DripTheme.technical),
                const SizedBox(height: 4),
                Text(
                  issueCount == 0
                      ? 'Production is coherent'
                      : '$issueCount issue${issueCount == 1 ? '' : 's'} need review',
                  style: DripTheme.meta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _toneColor(HealthTone t) {
  switch (t) {
    case HealthTone.good:
      return DripTheme.cosmicTeal;
    case HealthTone.warn:
      return const Color(0xFFE0C36A);
    case HealthTone.bad:
      return const Color(0xFFE8A0A0);
    case HealthTone.idle:
      return DripTheme.muted;
  }
}

class _MetricTile extends StatelessWidget {
  final HealthMetric m;
  const _MetricTile(this.m);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: DripTheme.surface,
          borderRadius: BorderRadius.circular(DripTheme.radiusMd),
          border: Border.all(color: DripTheme.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _toneColor(m.tone),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                      color: DripTheme.warmWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(m.detail, style: DripTheme.meta),
                ],
              ),
            ),
            Text(
              '${m.score}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _toneColor(m.tone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueTile extends StatelessWidget {
  final ContinuityIssue issue;
  const _IssueTile({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DripTheme.surface,
          borderRadius: BorderRadius.circular(DripTheme.radiusMd),
          border: Border.all(color: const Color(0x33E0C36A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue.type.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.6,
                color: Color(0xFFE0C36A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(issue.message, style: DripTheme.body.copyWith(fontSize: 13)),
            if (issue.autoFixable) ...[
              const SizedBox(height: 8),
              const Text(
                'AUTO-FIXABLE',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.4,
                  color: DripTheme.cosmicTeal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
