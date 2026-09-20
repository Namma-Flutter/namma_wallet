import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

void main() {
  group('PassengerInfo', () {
    test('should instantiate correctly', () {
      const passenger = PassengerInfo(
        name: 'John Doe',
        age: 30,
        type: 'Adult',
        gender: 'M',
        seatNumber: '12A',
      );
      expect(passenger.name, 'John Doe');
      expect(passenger.age, 30);
      expect(passenger.type, 'Adult');
      expect(passenger.gender, 'M');
      expect(passenger.seatNumber, '12A');
    });

    test('should instantiate with null fields', () {
      const passenger = PassengerInfo(
        name: 'Empty Seat',
      );
      expect(passenger.name, 'Empty Seat');
      expect(passenger.age, isNull);
      expect(passenger.type, isNull);
      expect(passenger.gender, isNull);
      expect(passenger.seatNumber, isNull);
    });

    test('toString should return a formatted string', () {
      const passenger = PassengerInfo(
        name: 'Jane Doe',
        age: 28,
        type: 'Adult',
        gender: 'F',
        seatNumber: '12B',
      );
      expect(
        passenger.toString(),
        'PassengerInfo(Name: Jane Doe, Age: 28, Type: Adult, '
        'Gender: F, Seat: 12B)',
      );
    });

    test('toString should handle null fields', () {
      const passenger = PassengerInfo(name: 'Jane Doe');
      expect(
        passenger.toString(),
        'PassengerInfo(Name: Jane Doe, Age: null, Type: null, '
        'Gender: null, Seat: null)',
      );
    });

    test('should support value equality', () {
      const passenger1 = PassengerInfo(
        name: 'John Doe',
        age: 30,
        type: 'Adult',
        gender: 'M',
        seatNumber: '12A',
      );
      const passenger2 = PassengerInfo(
        name: 'John Doe',
        age: 30,
        type: 'Adult',
        gender: 'M',
        seatNumber: '12A',
      );
      expect(passenger1, equals(passenger2));
    });

    test('should serialize and deserialize correctly with dart_mappable', () {
      const passenger = PassengerInfo(
        name: 'John Doe',
        age: 30,
        type: 'Adult',
        gender: 'M',
        seatNumber: '12A',
      );
      final json = passenger.toMap();
      final fromJson = PassengerInfoMapper.fromMap(json);
      expect(fromJson, equals(passenger));
    });
  });

  group('TNSTCTicketModel', () {
    test('should instantiate with minimal data', () {
      const model = TNSTCTicketModel();
      expect(model.pnrNumber, isNull);
      expect(model.passengers, isEmpty);
    });

    test('should instantiate with full data', () {
      final journeyDate = DateTime(2023, 12, 25);
      const passenger = PassengerInfo(
        name: 'Test Passenger',
        age: 25,
        type: 'Adult',
        gender: 'M',
        seatNumber: 'S1',
      );
      final model = TNSTCTicketModel(
        corporation: 'TNSTC',
        pnrNumber: 'PNR123',
        journeyDate: journeyDate,
        routeNo: '101',
        serviceStartPlace: 'Chennai',
        serviceEndPlace: 'Madurai',
        serviceStartTime: '10:00',
        passengers: [passenger],
        totalFare: 500,
        smsSeatNumbers: 'S1, S2',
      );

      expect(model.corporation, 'TNSTC');
      expect(model.pnrNumber, 'PNR123');
      expect(model.journeyDate, journeyDate);
      expect(model.routeNo, '101');
      expect(model.serviceStartPlace, 'Chennai');
      expect(model.serviceEndPlace, 'Madurai');
      expect(model.serviceStartTime, '10:00');
      expect(model.passengers.first, passenger);
      expect(model.totalFare, 500.0);
      expect(model.smsSeatNumbers, 'S1, S2');
    });

    group('Convenience Getters', () {
      test('displayPnr should return PNR or "Unknown"', () {
        expect(const TNSTCTicketModel(pnrNumber: '123').displayPnr, '123');
        expect(const TNSTCTicketModel().displayPnr, 'Unknown');
      });

      test('displayFrom should fallback correctly', () {
        expect(
          const TNSTCTicketModel(serviceStartPlace: 'A').displayFrom,
          'A',
        );
        expect(
          const TNSTCTicketModel(passengerStartPlace: 'B').displayFrom,
          'B',
        );
        expect(const TNSTCTicketModel().displayFrom, 'Unknown');
      });

      test('displayTo should fallback correctly', () {
        expect(const TNSTCTicketModel(serviceEndPlace: 'C').displayTo, 'C');
        expect(const TNSTCTicketModel(passengerEndPlace: 'D').displayTo, 'D');
        expect(const TNSTCTicketModel().displayTo, 'Unknown');
      });

      test('displayClass should return class or "Unknown"', () {
        expect(
          const TNSTCTicketModel(classOfService: 'AC').displayClass,
          'AC',
        );
        expect(const TNSTCTicketModel().displayClass, 'Unknown');
      });

      test('displayFare should return formatted fare or "₹0.00"', () {
        expect(
          const TNSTCTicketModel(totalFare: 123.45).displayFare,
          '₹123.45',
        );
        expect(const TNSTCTicketModel().displayFare, '₹0.00');
      });

      test('displayDate should return formatted date or "Unknown"', () {
        expect(
          TNSTCTicketModel(journeyDate: DateTime(2023, 5)).displayDate,
          '01/05/2023',
        );
        expect(const TNSTCTicketModel().displayDate, 'Unknown');
      });

      test('seatNumbers should prioritize smsSeatNumbers', () {
        const model = TNSTCTicketModel(
          smsSeatNumbers: 'S1,S2',
          passengers: [
            PassengerInfo(
              name: 'A',
              age: 1,
              type: 'a',
              gender: 'a',
              seatNumber: 'P1',
            ),
          ],
        );
        expect(model.seatNumbers, 'S1,S2');
      });

      test('seatNumbers should use passenger seats as fallback', () {
        const model = TNSTCTicketModel(
          passengers: [
            PassengerInfo(
              name: 'A',
              age: 1,
              type: 'a',
              gender: 'a',
              seatNumber: 'P1',
            ),
            PassengerInfo(
              name: 'B',
              age: 1,
              type: 'a',
              gender: 'a',
              seatNumber: 'P2',
            ),
          ],
        );
        expect(model.seatNumbers, 'P1, P2');
      });
    });

    test('toString should not throw', () {
      final model = TNSTCTicketModel(journeyDate: DateTime.now());
      expect(model.toString, returnsNormally);
    });

    test('should serialize and deserialize correctly with dart_mappable', () {
      final model = TNSTCTicketModel(
        pnrNumber: 'PNR567',
        totalFare: 99.99,
        journeyDate: DateTime.utc(2024),
        passengers: [
          const PassengerInfo(
            name: 'Test',
            age: 99,
            type: 'Test',
            gender: 'T',
            seatNumber: 'T99',
          ),
        ],
      );
      final json = model.toMap();
      final fromJson = TNSTCTicketModelMapper.fromMap(json);
      expect(fromJson, equals(model));
    });
  });
}
