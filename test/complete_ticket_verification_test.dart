import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

void main() {
  test(
    'Complete ticket verification with all fields from user raw PDF text',
    () {
      // Exact raw text from user's flutter logs
      const rawText = '''
Corporation: SETC
Tamil Nadu State Transport Corporation Ltd.
(A GOVERNMENT OF TAMILNADU UNDERTAKING)
Date of Journey: 18/01/2026
Service Start Place: KUMBAKONAM
Name
Service Start Time: 13:15 Hrs.
Passenger Start Place: KUMBAKONAM
Passenger Pickup Point: KUMBAKONAM
Platform Number:
Trip Code: 1315KUMCHEAB
No. of Seats: 1 (Adults=1 Children=0)
Bus ID No. : E-5494
Passenger Information
HarishAnbalagan
E-Ticket/Reservation Voucher-H
ID Card Type rD Card
Important
Government Issued Photo
Total Fare: 735.00 Rs.
transferable.
Age
26
PNR Number: T73309927
Route No: 307AB
Service End Place: CHENNAI-PT DR. M.G.R. BS
circumstances.
Passenger End Place: CHENNAI-PT Dr.M.G.R. BS
Passenger Pickup Time: 18/01/2026 13:15 Hrs.
Class of Service: AC SLEEPER SEATER
OB Reference No. : OB31475439
Bank Txn. No; : BAX6K8N12PUH74
Passenger category: GENERAL PUBLIc
Adult/Child
Adult
Gender
M
• The seat(s) booked under this ticket is/are not
ID Card Number: 736960775578
• This e-ticket is valid only for the seat num
''';

      final parser = TNSTCPDFParser();
      final ticket = parser.parseTicket(rawText);

      // Assertions for date fields
      expect(ticket.journeyDate, isNotNull);
      expect(ticket.journeyDate!.year, 2026);
      expect(ticket.journeyDate!.month, 1);
      expect(ticket.journeyDate!.day, 18);

      expect(ticket.passengerPickupTime, isNotNull);
      expect(ticket.passengerPickupTime!.year, 2026);
      expect(ticket.passengerPickupTime!.month, 1);
      expect(ticket.passengerPickupTime!.day, 18);
      expect(ticket.passengerPickupTime!.hour, 13);
      expect(ticket.passengerPickupTime!.minute, 15);

      expect(ticket.serviceStartTime, '13:15');

      // Assertions for other critical fields
      expect(ticket.corporation, 'SETC');
      expect(ticket.pnrNumber, 'T73309927');
      expect(ticket.routeNo, '307AB');
      expect(ticket.serviceStartPlace, 'KUMBAKONAM');
      expect(ticket.serviceEndPlace, 'CHENNAI-PT DR. M.G.R. BS');
      expect(ticket.passengerPickupPoint, 'KUMBAKONAM');
      expect(ticket.tripCode, '1315KUMCHEAB');
      expect(ticket.obReferenceNumber, 'OB31475439');
      expect(ticket.numberOfSeats, 1);
      expect(ticket.bankTransactionNumber, 'BAX6K8N12PUH74');
      expect(ticket.busIdNumber, 'E-5494');
      expect(ticket.totalFare, 735.0);
      expect(ticket.boardingPoint, 'KUMBAKONAM');

      // Passenger assertions
      expect(ticket.passengers, isNotEmpty);
      expect(ticket.passengers.first.name, 'HarishAnbalagan');
      expect(ticket.passengers.first.age, 26);
      expect(ticket.passengers.first.type, 'Adult');
      expect(ticket.passengers.first.gender, 'M');
    },
  );
}
