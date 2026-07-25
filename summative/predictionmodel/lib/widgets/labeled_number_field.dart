import 'package:flutter/material.dart';

import '../models/field_config.dart';
import '../theme/app_colors.dart';

class LabeledNumberField extends StatelessWidget {
  final FieldConfig config;
  final TextEditingController controller;
  final Color accentColor;

  const LabeledNumberField({
    super.key,
    required this.config,
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final radius = BorderRadius.circular(12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: config.unit,
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: accentColor, width: 1.6),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '${config.label} is required';
            }
            final parsed = double.tryParse(value);
            if (parsed == null) {
              return 'Enter a valid number';
            }
            if (parsed < config.min || parsed > config.max) {
              return 'Must be between ${config.rangeLabel}';
            }
            return null;
          },
        ),
        const SizedBox(height: 3),
        Text(
          config.rangeLabel,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colors.muted),
        ),
      ],
    );
  }
}
