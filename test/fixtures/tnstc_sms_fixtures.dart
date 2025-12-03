/// Real TNSTC SMS data fixtures for testing
/// IMPORTANT: Never use generated mock data - these are real SMS examples
class TnstcSmsFixtures {
  /// SETC SMS - Kumbakonam to Chennai (AC Sleeper Seater)
  static const String setcKumbakonamToChennai = '''
TNSTC Corporation:SETC , PNR NO.:T73309927 , From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , Trip Code:1315KUMCHEAB , Journey Date:18/01/2026 , Time:,13:15 , Seat No.:4UB .Class:AC SLEEPER SEATER , Boarding at:KUMBAKONAM . For  e-Ticket: Download from View Ticket. Please carry your photo ID during journey. T&C apply. https://www.radiantinfo.com
''';

  /// SETC SMS - Chennai to Kumbakonam (Non-AC Lower Berth)
  static const String setcChennaiToKumbakonam = '''
TNSTC Corporation:SETC , PNR NO.:T69704790 , From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , Trip Code:2300CHEKUMLB , Journey Date:17/10/2025 , Time:23:55 , Seat No.:1 UB, .Class:NON AC LOWER BERTH SEATER , Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from View Ticket. Please carry your photo ID during journey. T&C apply. https://www.radiantinfo.com
''';

  /// TNSTC Update SMS - Conductor and vehicle details for PNR T69704790
  static const String tnstcUpdateSms1 = '''
* TNSTC * PNR:T69704790, DOJ:17/10/2025, Conductor Mobile No: 9944501917, Vehicle No:TN01AN4404, Route No:307ELB. Click https://www.tnstc.in/SETCWeb/FB.do Share your Comments https://www.radiantinfo.com
''';

  /// Coimbatore Division - Kumbakonam to Coimbatore (Deluxe)
  static const String coimbatoreKumbakonamToCoimbatore = '''
TNSTC Corporation:COIMBATORE , PNR NO.:U70109781 , From:KUMBAKONAM To COIMBATORE , Trip Code:0400KUMCOICC01L , Journey Date:30/08/2025 , Time:,04:00 , Seat No.:24 .Class:DELUXE 3X2 , Boarding at:KUMBAKONAM . For e-Ticket: Download from View Ticket. Please carry your photo ID during journey. T&C apply. https://www.radiantinfo.com
''';

  /// TNSTC Update SMS - Conductor and vehicle details for PNR T69705233
  static const String tnstcUpdateSms2 = '''
* TNSTC * PNR:T69705233, DOJ:21/10/2025, Conductor Mobile No: 8870571461, Vehicle No:TN01AN4317, Route No:307LB. Click https://www.tnstc.in/SETCWeb/FB.do Share your Comments https://www.radiantinfo.com
''';

  /// SETC SMS - Kumbakonam to Chennai (Non-AC Lower Berth)
  static const String setcKumbakonamToChennai2 = '''
TNSTC Corporation:SETC , PNR NO.:T69705233 , From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , Trip Code:2100KUMCHELB , Journey Date:21/10/2025 , Time:,21:00 , Seat No.:4LB .Class:NON AC LOWER BERTH SEATER , Boarding at:KUMBAKONAM . For e-Ticket: Download from View Ticket. Please carry your photo ID during journey. T&C apply. https://www.radiantinfo.com
''';

  /// All booking SMS messages
  static const List<String> allBookingSms = [
    setcKumbakonamToChennai,
    setcChennaiToKumbakonam,
    coimbatoreKumbakonamToCoimbatore,
    setcKumbakonamToChennai2,
  ];

  /// All update SMS messages
  static const List<String> allUpdateSms = [
    tnstcUpdateSms1,
    tnstcUpdateSms2,
  ];

  /// Get PNR from booking SMS by index
  static String getPnrFromBooking(int index) {
    const pnrs = [
      'T73309927',
      'T69704790',
      'U70109781',
      'T69705233',
    ];
    return pnrs[index];
  }

  /// Get PNR from update SMS by index
  static String getPnrFromUpdate(int index) {
    const pnrs = [
      'T69704790',
      'T69705233',
    ];
    return pnrs[index];
  }
}
