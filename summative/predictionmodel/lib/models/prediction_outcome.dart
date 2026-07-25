sealed class PredictionOutcome {
  const PredictionOutcome();
}

class PredictionSuccess extends PredictionOutcome {
  final double numberCaseMalaria;

  const PredictionSuccess(this.numberCaseMalaria);
}

class PredictionFailure extends PredictionOutcome {
  final String message;

  const PredictionFailure(this.message);
}
