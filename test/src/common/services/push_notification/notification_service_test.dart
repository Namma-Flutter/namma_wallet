import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/services/push_notification/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class ThrowingTimezoneNotificationService extends NotificationService {
  ThrowingTimezoneNotificationService() : super.internal();

  @override
  Future<String> getLocalTimezoneId() async {
    throw Exception('Platform channel failed to lookup timezone');
  }
}

class InvalidTimezoneNotificationService extends NotificationService {
  InvalidTimezoneNotificationService() : super.internal();

  @override
  Future<String> getLocalTimezoneId() async {
    return 'Invalid/NonExistent_Timezone';
  }
}

class CalcuttaTimezoneNotificationService extends NotificationService {
  CalcuttaTimezoneNotificationService() : super.internal();

  @override
  Future<String> getLocalTimezoneId() async {
    return 'Asia/Calcutta';
  }
}

class ValidTimezoneNotificationService extends NotificationService {
  ValidTimezoneNotificationService() : super.internal();

  @override
  Future<String> getLocalTimezoneId() async {
    return 'America/New_York';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService initTimezone Tests', () {
    test(
      'Given timezone lookup failure, '
      'When initTimezone is called, '
      'Then UTC is selected as fallback and initialization completes',
      () async {
        final service = ThrowingTimezoneNotificationService();

        await expectLater(service.initTimezone(), completes);
        expect(tz.local.name, equals('UTC'));
      },
    );

    test(
      'Given invalid timezone ID, '
      'When initTimezone is called, '
      'Then UTC is selected as fallback and initialization completes',
      () async {
        final service = InvalidTimezoneNotificationService();

        await expectLater(service.initTimezone(), completes);
        expect(tz.local.name, equals('UTC'));
      },
    );

    test(
      'Given Asia/Calcutta timezone, '
      'When initTimezone is called, '
      'Then Asia/Kolkata is selected',
      () async {
        final service = CalcuttaTimezoneNotificationService();

        await service.initTimezone();
        expect(tz.local.name, equals('Asia/Kolkata'));
      },
    );

    test(
      'Given valid timezone ID, '
      'When initTimezone is called, '
      'Then corresponding timezone location is set',
      () async {
        final service = ValidTimezoneNotificationService();

        await service.initTimezone();
        expect(tz.local.name, equals('America/New_York'));
      },
    );
  });
}
