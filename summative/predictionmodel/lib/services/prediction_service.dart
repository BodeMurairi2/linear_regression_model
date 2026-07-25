import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prediction_outcome.dart';
import '../models/prediction_request.dart';

class PredictionService {
  static const String baseUrl = 'https://malaria-prevalence.onrender.com';
  static const String predictPath = '/predictions/';

  Future<PredictionOutcome> predict(PredictionRequest request) async {
    final uri = Uri.parse('$baseUrl$predictPath');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final prediction = body['Prediction'] as Map<String, dynamic>?;
        final value = prediction?['number_case_malaria'];
        if (value is num) {
          return PredictionSuccess(value.toDouble());
        }
        return const PredictionFailure(
          'The server response was missing a prediction value.',
        );
      }

      if (response.statusCode == 422) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return PredictionFailure(_describeValidationError(body['detail']));
      }

      return PredictionFailure(
        'Prediction failed (HTTP ${response.statusCode}). Please try again.',
      );
    } on http.ClientException {
      return const PredictionFailure(
        'Could not reach the server. Check your connection and try again.',
      );
    } on FormatException {
      return const PredictionFailure(
        'Received an unexpected response from the server.',
      );
    } catch (_) {
      return const PredictionFailure(
        'Something went wrong while predicting. Please try again.',
      );
    }
  }

  String _describeValidationError(dynamic detail) {
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] != null && first['loc'] is List) {
        final loc = first['loc'] as List;
        final field = loc.isNotEmpty ? loc.last : 'value';
        return '$field: ${first['msg']}';
      }
    }
    if (detail is String) return detail;
    return 'One or more values are out of the accepted range.';
  }
}
