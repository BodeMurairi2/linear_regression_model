import 'package:flutter/material.dart';

import '../models/field_config.dart';
import '../models/prediction_outcome.dart';
import '../models/prediction_request.dart';
import '../services/prediction_service.dart';
import '../theme/app_colors.dart';
import '../widgets/predict_button.dart';
import '../widgets/result_card.dart';
import '../widgets/section_card.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PredictionService();
  final Map<String, TextEditingController> _controllers = {};

  bool _isLoading = false;
  PredictionOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    for (final fields in fieldGroups.values) {
      for (final field in fields) {
        _controllers[field.key] = TextEditingController(
          text: field.initial.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handlePredict() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _outcome = null;
    });

    final values = {
      for (final entry in _controllers.entries)
        entry.key: double.parse(entry.value.text),
    };

    final outcome = await _service.predict(PredictionRequest(values));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _outcome = outcome;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Malaria Prevalence Estimater',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'per 1,000 cases at risk',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.muted),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: colors.line),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              for (final group in fieldGroups.keys) ...[
                SectionCard(group: group, controllers: _controllers),
                const SizedBox(height: 16),
              ],
              PredictButton(isLoading: _isLoading, onPressed: _handlePredict),
              const SizedBox(height: 16),
              ResultCard(outcome: _outcome),
            ],
          ),
        ),
      ),
    );
  }
}
