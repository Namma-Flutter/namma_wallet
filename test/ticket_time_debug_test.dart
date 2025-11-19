import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

void main() {
  test('Debug ticket time from PDF parsing to Ticket creation', () {
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
    final tnstcTicket = parser.parseTicket(rawText);

    // Create the final Ticket object
    final ticket = Ticket.fromTNSTC(tnstcTicket);

    // Verify the time is correct
    expect(ticket.startTime.hour, 13, reason: 'Hour should be 13 (1:15 PM)');
    expect(ticket.startTime.minute, 15, reason: 'Minute should be 15');
    expect(ticket.startTime.year, 2026);
    expect(ticket.startTime.month, 1);
    expect(ticket.startTime.day, 18);
  });
}
