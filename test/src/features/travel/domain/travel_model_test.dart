import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/travel/domain/travel_model.dart';

void main() {
  group('TravelModel Tests', () {
    group('Model Creation - Success Scenarios', () {
      test(
        'Given all valid parameters, When creating TravelModel, '
        'Then creates model with all fields correctly',
        () {
          // Arrange & Act (Given & When)
          const model = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['12', '13'],
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          // Assert (Then)
          expect(model.corporation, equals('TNSTC'));
          expect(model.service, equals('Express'));
          expect(model.pnrNo, equals('T123456789'));
          expect(model.from, equals('Chennai'));
          expect(model.to, equals('Bangalore'));
          expect(model.tripCode, equals('12345'));
          expect(model.journeyDate, equals('15/12/2024'));
          expect(model.time, equals('14:30'));
          expect(model.seatNumbers, equals(['12', '13']));
          expect(model.ticketClass, equals('Seater'));
          expect(model.boardingAt, equals('Koyambedu'));
        },
      );

      test(
        'Given model with single seat, When creating TravelModel, '
        'Then creates model with single seat in list',
        () {
          // Arrange & Act (Given & When)
          const model = TravelModel(
            corporation: 'SETC',
            service: 'Regular',
            pnrNo: 'S987654321',
            from: 'Madurai',
            to: 'Chennai',
            tripCode: '54321',
            journeyDate: '20/12/2024',
            time: '09:00',
            seatNumbers: ['5'],
            ticketClass: 'Sleeper',
            boardingAt: 'Periyar Bus Stand',
          );

          // Assert (Then)
          expect(model.seatNumbers, equals(['5']));
          expect(model.seatNumbers.length, equals(1));
        },
      );

      test(
        'Given model with multiple seats, When creating TravelModel, '
        'Then creates model with all seats in list',
        () {
          // Arrange & Act (Given & When)
          const model = TravelModel(
            corporation: 'TNSTC',
            service: 'Ultra Deluxe',
            pnrNo: 'T111222333',
            from: 'Coimbatore',
            to: 'Chennai',
            tripCode: '99999',
            journeyDate: '25/12/2024',
            time: '18:00',
            seatNumbers: ['1', '2', '3', '4'],
            ticketClass: 'AC',
            boardingAt: 'Gandhipuram',
          );

          // Assert (Then)
          expect(model.seatNumbers.length, equals(4));
          expect(model.seatNumbers, containsAll(['1', '2', '3', '4']));
        },
      );

      test(
        'Given model with empty strings, When creating TravelModel, '
        'Then creates model with empty string values',
        () {
          // Arrange & Act (Given & When)
          const model = TravelModel(
            corporation: '',
            service: '',
            pnrNo: '',
            from: '',
            to: '',
            tripCode: '',
            journeyDate: '',
            time: '',
            seatNumbers: [],
            ticketClass: '',
            boardingAt: '',
          );

          // Assert (Then)
          expect(model.corporation, isEmpty);
          expect(model.service, isEmpty);
          expect(model.pnrNo, isEmpty);
          expect(model.from, isEmpty);
          expect(model.to, isEmpty);
          expect(model.seatNumbers, isEmpty);
        },
      );
    });

    group('Model Serialization - JSON Mapping', () {
      test(
        'Given TravelModel, When converting to JSON, '
        'Then creates JSON string',
        () {
          // Arrange (Given)
          const model = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['12', '13'],
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          // Act (When)
          final json = model.toJson();

          // Assert (Then)
          expect(json, isA<String>());
          expect(json, contains('TNSTC'));
          expect(json, contains('Express'));
          expect(json, contains('T123456789'));
        },
      );

      test(
        'Given JSON string, When creating TravelModel from JSON, '
        'Then creates correct model instance',
        () {
          // Arrange (Given)
          const jsonStr = '''
{
  "corporation": "SETC",
  "service": "Regular",
  "pnr_no": "S987654321",
  "from": "Madurai",
  "to": "Chennai",
  "trip_code": "54321",
  "journey_date": "20/12/2024",
  "time": "09:00",
  "seat_numbers": ["5", "6"],
  "class": "Sleeper",
  "boarding_at": "Periyar Bus Stand"
}
''';

          // Act (When)
          final model = TravelModelMapper.fromJson(jsonStr);

          // Assert (Then)
          expect(model.corporation, equals('SETC'));
          expect(model.service, equals('Regular'));
          expect(model.pnrNo, equals('S987654321'));
          expect(model.from, equals('Madurai'));
          expect(model.to, equals('Chennai'));
          expect(model.tripCode, equals('54321'));
          expect(model.journeyDate, equals('20/12/2024'));
          expect(model.time, equals('09:00'));
          expect(model.seatNumbers, equals(['5', '6']));
          expect(model.ticketClass, equals('Sleeper'));
          expect(model.boardingAt, equals('Periyar Bus Stand'));
        },
      );

      test(
        'Given model, When round-trip JSON conversion, '
        'Then maintains all data correctly',
        () {
          // Arrange (Given)
          const originalModel = TravelModel(
            corporation: 'TNSTC',
            service: 'Ultra Deluxe',
            pnrNo: 'T111222333',
            from: 'Coimbatore',
            to: 'Chennai',
            tripCode: '99999',
            journeyDate: '25/12/2024',
            time: '18:00',
            seatNumbers: ['1', '2'],
            ticketClass: 'AC',
            boardingAt: 'Gandhipuram',
          );

          // Act (When)
          final json = originalModel.toJson();
          final restoredModel = TravelModelMapper.fromJson(json);

          // Assert (Then)
          expect(restoredModel.corporation, equals(originalModel.corporation));
          expect(restoredModel.service, equals(originalModel.service));
          expect(restoredModel.pnrNo, equals(originalModel.pnrNo));
          expect(restoredModel.from, equals(originalModel.from));
          expect(restoredModel.to, equals(originalModel.to));
          expect(restoredModel.tripCode, equals(originalModel.tripCode));
          expect(
            restoredModel.journeyDate,
            equals(originalModel.journeyDate),
          );
          expect(restoredModel.time, equals(originalModel.time));
          expect(restoredModel.seatNumbers, equals(originalModel.seatNumbers));
          expect(
            restoredModel.ticketClass,
            equals(originalModel.ticketClass),
          );
          expect(restoredModel.boardingAt, equals(originalModel.boardingAt));
        },
      );
    });

    group('Model Equality and Comparison', () {
      test(
        'Given two identical models, When comparing, '
        'Then models are equal',
        () {
          // Arrange (Given)
          const model1 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['12', '13'],
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          const model2 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['12', '13'],
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          // Act & Assert (When & Then)
          expect(model1, equals(model2));
          expect(model1.hashCode, equals(model2.hashCode));
        },
      );

      test(
        'Given two different models, When comparing, '
        'Then models are not equal',
        () {
          // Arrange (Given)
          const model1 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['12', '13'],
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          const model2 = TravelModel(
            corporation: 'SETC',
            service: 'Regular',
            pnrNo: 'S987654321',
            from: 'Madurai',
            to: 'Chennai',
            tripCode: '54321',
            journeyDate: '20/12/2024',
            time: '09:00',
            seatNumbers: ['5', '6'],
            ticketClass: 'Sleeper',
            boardingAt: 'Periyar Bus Stand',
          );

          // Act & Assert (When & Then)
          expect(model1, isNot(equals(model2)));
        },
      );

      test(
        'Given models differing only in one field, When comparing, '
        'Then models are not equal',
        () {
          // Arrange (Given)
          const model1 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['12', '13'],
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          const model2 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['14', '15'], // Different seats
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          // Act & Assert (When & Then)
          expect(model1, isNot(equals(model2)));
        },
      );
    });

    group('Edge Cases and Boundary Conditions', () {
      test(
        'Given model with very long strings, When creating TravelModel, '
        'Then creates model successfully',
        () {
          // Arrange & Act (Given & When)
          final longString = 'A' * 1000;
          final model = TravelModel(
            corporation: longString,
            service: longString,
            pnrNo: longString,
            from: longString,
            to: longString,
            tripCode: longString,
            journeyDate: longString,
            time: longString,
            seatNumbers: [longString],
            ticketClass: longString,
            boardingAt: longString,
          );

          // Assert (Then)
          expect(model.corporation.length, equals(1000));
          expect(model.service.length, equals(1000));
        },
      );

      test(
        'Given model with special characters, When creating TravelModel, '
        'Then creates model successfully',
        () {
          // Arrange & Act (Given & When)
          const model = TravelModel(
            corporation: r'TNSTC@#$%',
            service: 'Express & Regular',
            pnrNo: 'T-123/456',
            from: 'Chennai (Central)',
            to: 'Bangalore [City]',
            tripCode: '12-34-5',
            journeyDate: '15/12/2024',
            time: '14:30 hrs',
            seatNumbers: ['12A', '13B'],
            ticketClass: 'Seater/AC',
            boardingAt: 'Koyambedu (Main)',
          );

          // Assert (Then)
          expect(model.corporation, contains(r'@#$%'));
          expect(model.service, contains('&'));
        },
      );

      test(
        'Given model with Unicode characters, When creating TravelModel, '
        'Then creates model successfully',
        () {
          // Arrange & Act (Given & When)
          const model = TravelModel(
            corporation: 'தமிழ்நாடு பேருந்து',
            service: 'விரைவு சேவை',
            pnrNo: 'T123456789',
            from: 'சென்னை',
            to: 'பெங்களூரு',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['12', '13'],
            ticketClass: 'இருக்கை',
            boardingAt: 'கோயம்பேடு',
          );

          // Assert (Then)
          expect(model.corporation, equals('தமிழ்நாடு பேருந்து'));
          expect(model.from, equals('சென்னை'));
        },
      );

      test(
        'Given model with empty seat numbers list, When creating TravelModel, '
        'Then creates model with empty list',
        () {
          // Arrange & Act (Given & When)
          const model = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: [],
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          // Assert (Then)
          expect(model.seatNumbers, isEmpty);
          expect(model.seatNumbers.length, equals(0));
        },
      );

      test(
        'Given model with many seat numbers, When creating TravelModel, '
        'Then creates model with all seats',
        () {
          // Arrange & Act (Given & When)
          final manySeats = List.generate(50, (i) => '${i + 1}');
          final model = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T123456789',
            from: 'Chennai',
            to: 'Bangalore',
            tripCode: '12345',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: manySeats,
            ticketClass: 'Seater',
            boardingAt: 'Koyambedu',
          );

          // Assert (Then)
          expect(model.seatNumbers.length, equals(50));
          expect(model.seatNumbers.first, equals('1'));
          expect(model.seatNumbers.last, equals('50'));
        },
      );
    });

    group('Field-Specific Tests', () {
      test(
        'Given different time formats, When creating TravelModel, '
        'Then accepts various time formats',
        () {
          // Arrange & Act (Given & When)
          const model1 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T1',
            from: 'A',
            to: 'B',
            tripCode: '1',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['1'],
            ticketClass: 'Seater',
            boardingAt: 'X',
          );

          const model2 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T2',
            from: 'A',
            to: 'B',
            tripCode: '2',
            journeyDate: '15/12/2024',
            time: '14:30 hrs',
            seatNumbers: ['2'],
            ticketClass: 'Seater',
            boardingAt: 'X',
          );

          const model3 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T3',
            from: 'A',
            to: 'B',
            tripCode: '3',
            journeyDate: '15/12/2024',
            time: '2:30 PM',
            seatNumbers: ['3'],
            ticketClass: 'Seater',
            boardingAt: 'X',
          );

          // Assert (Then)
          expect(model1.time, equals('14:30'));
          expect(model2.time, equals('14:30 hrs'));
          expect(model3.time, equals('2:30 PM'));
        },
      );

      test(
        'Given different date formats, When creating TravelModel, '
        'Then accepts various date formats',
        () {
          // Arrange & Act (Given & When)
          const model1 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T1',
            from: 'A',
            to: 'B',
            tripCode: '1',
            journeyDate: '15/12/2024',
            time: '14:30',
            seatNumbers: ['1'],
            ticketClass: 'Seater',
            boardingAt: 'X',
          );

          const model2 = TravelModel(
            corporation: 'TNSTC',
            service: 'Express',
            pnrNo: 'T2',
            from: 'A',
            to: 'B',
            tripCode: '2',
            journeyDate: '15-12-2024',
            time: '14:30',
            seatNumbers: ['2'],
            ticketClass: 'Seater',
            boardingAt: 'X',
          );

          // Assert (Then)
          expect(model1.journeyDate, equals('15/12/2024'));
          expect(model2.journeyDate, equals('15-12-2024'));
        },
      );
    });
  });
}
