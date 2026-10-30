import 'package:flutter/material.dart';
import '../../models/continuity_score.dart';
import '../../core/theme.dart';

class ContinuityScoreCard extends StatelessWidget {
  final ContinuityScore score;
  final VoidCallback? onFixPressed;

  const ContinuityScoreCard({
    super.key,
    required this.score,
    this.onFixPressed,
  });

  @override
  Widget build(BuildContext context) {
    final overallPct = (score.overall * 100).round();
    final color = _scoreColor(score.overall);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: DripTheme.gunmetal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: color),
                const SizedBox(width: 8),
                const Text(
                  'Continuity Health',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '$overallPct%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricRow(label: 'Character', value: score.character),
            _MetricRow(label: 'Wardrobe', value: score.wardrobe),
            _MetricRow(label: 'Props', value: score.props),
            _MetricRow(label: 'Environment', value: score.environment),
            _MetricRow(label: 'Timeline', value: score.timeline),
            if (score.issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Issues', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ...score.issues.map((issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(issue, style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  )),
            ],
            if (onFixPressed != null && score.issues.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onFixPressed,
                  child: const Text('Review & Fix'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double value) {
    if (value >= 0.9) return Colors.green;
    if (value >= 0.7) return Colors.orange;
    return Colors.red;
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade800,
              color: value >= 0.9
                  ? Colors.green
                  : value >= 0.7
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text('${(value * 100).round()}%', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
