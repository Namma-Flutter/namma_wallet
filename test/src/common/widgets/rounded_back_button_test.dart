import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';

class MockHapticService extends Mock implements IHapticService {
  void triggerHaptic(HapticType type) {
    super.noSuchMethod(
      Invocation.method(#triggerHaptic, [type]),
      returnValueForMissingStub: null,
    );
  }
}

void main() {
  setUp(getIt.reset);

  testWidgets('RoundedBackButton triggers haptic on tap', (tester) async {
    final mockHapticService = MockHapticService();
    getIt.registerSingleton<IHapticService>(mockHapticService);

    var wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundedBackButton(
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RoundedBackButton));
    await tester.pumpAndSettle();

    verify(mockHapticService.triggerHaptic(HapticType.selection)).called(1);
    expect(wasPressed, isTrue);
  });
}
