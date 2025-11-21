import 'dart:io';

import 'package:namma_wallet/src/features/tnstc/domain/ocr_service_interface.dart';

class MockOCRService implements IOCRService {
  @override
  Future<String> extractTextFromPDF(File pdfFile) async {
    return '''
Tamil Nadu State Transport Corporation Ltd.
E-Ticket/Reservation Voucher-H

Corporation: SETC
PNR Number: T73309927
Date of Journey: 18/01/2026
Route No: 307AB
Service Start Place: KUMBAKONAM
Service End Place: CHENNAI-PT DR. M.G.R. BS
Service Start Time: 13:15 Hrs.
Passenger Start Place: KUMBAKONAM
Passenger End Place: CHENNAI-PT Dr.M.G.R. BS
Passenger Pickup Point: KUMBAKONAM
Passenger Pickup Time: 18/01/2026 13:15 Hrs.
Platform Number:
Trip Code: 1315KUMCHEAB
Class of Service: AC SLEEPER SEATER
OB Reference No.: OB31475439
No. of Seats: 1 (Adults=1 Children=0)
Bank Txn. No.: BAX6K8N12PUH74
Bus ID No.: E-5494
Passenger category: GENERAL PUBLIC

Passenger Information
Name                    Age    Adult/Child    Gender    Seat No.
HarishAnbalagan         26     Adult          M         4UB
ID Card Type: Government Issued Photo ID Card
ID Card Number: 736960775578

Total Fare: 735.00 Rs.
''';
  }
}
