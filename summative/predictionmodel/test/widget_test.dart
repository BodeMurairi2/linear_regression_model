import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:predictionmodel/main.dart';

void main() {
  testWidgets('Prediction screen shows all inputs and the Predict button', (
    WidgetTester tester,
  ) async {
    // The form is taller than the default test viewport, so give it enough
    // room that every field and the button are actually built and visible.
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MalariaEstimaterApp());

    expect(find.text('Predict'), findsOneWidget);
    expect(find.text('Health system & outcomes'), findsOneWidget);
    expect(find.text('Economy & demographics'), findsOneWidget);
    expect(find.text('Environment & education'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(11));
  });
}
