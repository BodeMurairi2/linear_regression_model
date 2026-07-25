import 'package:flutter/material.dart';

import '../models/prediction_outcome.dart';
import '../theme/app_colors.dart';

/// The single display area for either the predicted value or an error
/// message, as required by the task spec.
class ResultCard extends StatelessWidget {
  final PredictionOutcome? outcome;

  const ResultCard({super.key, this.outcome});

  @override
  Widget build(BuildContext context) {
    final current = outcome;
    if (current == null) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).extension<AppColors>()!;
    final isError = current is PredictionFailure;
    final tint = isError ? colors.coral : colors.teal;
    final tintSoft = isError ? colors.coralSoft : colors.tealSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tintSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                size: 16,
                color: tint,
              ),
              const SizedBox(width: 6),
              Text(
                isError ? 'Could not predict' : 'Estimated malaria incidence',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (current is PredictionSuccess)
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(text: current.numberCaseMalaria.round().toString()),
                  TextSpan(
                    text: '  per 1,000 at risk',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.muted),
                  ),
                ],
              ),
            )
          else if (current is PredictionFailure)
            Text(
              current.message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
        ],
      ),
    );
  }
}
