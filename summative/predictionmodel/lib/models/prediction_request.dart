class PredictionRequest {
  final Map<String, double> values;

  const PredictionRequest(this.values);

  Map<String, dynamic> toJson() => values;
}
