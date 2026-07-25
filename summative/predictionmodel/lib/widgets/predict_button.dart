import 'package:flutter/material.dart';

class PredictButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const PredictButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.query_stats_rounded, size: 20),
        label: Text(isLoading ? 'Predicting…' : 'Predict'),
      ),
    );
  }
}
