import 'package:flutter/material.dart';

import '../models/field_config.dart';
import '../theme/app_colors.dart';
import 'labeled_number_field.dart';

class SectionCard extends StatelessWidget {
  final FieldGroup group;
  final Map<String, TextEditingController> controllers;

  const SectionCard({super.key, required this.group, required this.controllers});

  (Color accent, Color soft) _palette(AppColors colors) {
    switch (group) {
      case FieldGroup.healthSystem:
        return (colors.teal, colors.tealSoft);
      case FieldGroup.economyDemographics:
        return (colors.gold, colors.goldSoft);
      case FieldGroup.environmentEducation:
        return (colors.forest, colors.forestSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final (accent, soft) = _palette(colors);
    final fields = fieldGroups[group]!;
    final radius = BorderRadius.circular(18);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
                            child: Icon(fieldGroupIcons[group], size: 17, color: accent),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              fieldGroupTitles[group]!,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24, color: colors.line),
                      for (final field in fields) ...[
                        LabeledNumberField(
                          config: field,
                          controller: controllers[field.key]!,
                          accentColor: accent,
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
