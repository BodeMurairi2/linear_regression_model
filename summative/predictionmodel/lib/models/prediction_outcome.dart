class FeatureContribution {
  final String feature;
  final double contribution;

  const FeatureContribution({required this.feature, required this.contribution});

  factory FeatureContribution.fromJson(Map<String, dynamic> json) {
    return FeatureContribution(
      feature: json['feature'] as String,
      contribution: (json['contribution'] as num).toDouble(),
    );
  }
}

sealed class PredictionOutcome {
  const PredictionOutcome();
}

class PredictionSuccess extends PredictionOutcome {
  final double numberCaseMalaria;
  final List<FeatureContribution> contributions;

  const PredictionSuccess(this.numberCaseMalaria, {this.contributions = const []});
}

class PredictionFailure extends PredictionOutcome {
  final String message;

  const PredictionFailure(this.message);
}
