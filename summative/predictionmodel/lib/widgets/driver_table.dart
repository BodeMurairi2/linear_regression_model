import 'package:flutter/material.dart';

import '../models/field_config.dart';
import '../models/prediction_outcome.dart';
import '../theme/app_colors.dart';

/// "What's driving this estimate" — a real, per-prediction SHAP breakdown
/// from the deployed RandomForestRegressor, not illustrative numbers.
class DriverTable extends StatelessWidget {
  final List<FeatureContribution> contributions;

  const DriverTable({super.key, required this.contributions});

  @override
  Widget build(BuildContext context) {
    if (contributions.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).extension<AppColors>()!;
    final sorted = [...contributions]
      ..sort((a, b) => b.contribution.abs().compareTo(a.contribution.abs()));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.query_stats_rounded, size: 16, color: colors.teal),
              const SizedBox(width: 6),
              Text(
                "What's driving this estimate",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _legendDot(colors.teal),
              const SizedBox(width: 6),
              Text(
                'Lowers estimate',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.muted),
              ),
              const SizedBox(width: 16),
              _legendDot(colors.coral),
              const SizedBox(width: 6),
              Text(
                'Raises estimate',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.muted),
              ),
            ],
          ),
          Divider(height: 22, color: colors.line),
          for (var i = 0; i < sorted.length; i++) ...[
            _DriverRow(item: sorted[i], colors: colors),
            if (i != sorted.length - 1) Divider(height: 20, color: colors.line),
          ],
        ],
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}

class _DriverRow extends StatelessWidget {
  final FeatureContribution item;
  final AppColors colors;

  const _DriverRow({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    final config = fieldConfigByKey[item.feature];
    final isPositive = item.contribution > 0;
    final tint = isPositive ? colors.coral : colors.teal;
    final tintSoft = isPositive ? colors.coralSoft : colors.tealSoft;
    final sign = isPositive ? '+' : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config?.label ?? item.feature,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (config != null) ...[
                const SizedBox(height: 2),
                Text(
                  config.description,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: colors.muted, height: 1.35),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: tintSoft, borderRadius: BorderRadius.circular(999)),
          child: Text(
            '$sign${item.contribution.round()}',
            style: TextStyle(
              color: tint,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
