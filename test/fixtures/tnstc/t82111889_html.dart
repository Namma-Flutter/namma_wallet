// coverage:ignore-file
// HTML fixture for TNSTC PNR T82111889 — reflects the actual response from
// https://www.tnstc.in/OTRSOnline/manageKnowYourConductor.do
//
// Verified by live fetch on 22/06/2026.
//
// Key findings from the real TNSTC API:
//   • There is NO "Journey Date" field — the API does NOT return the travel date.
//   • "Booking Date" = ticket-purchase date (NOT journey date).
//   • The journey date is absent from the API response and must remain null.
//   • Phone field label is "Mobile no" (lowercase "no").
//   • Each row has 4 cols (col-6 col-md-3): label, value, label, value.
//   • Labels sometimes lack the trailing colon (e.g. "Trip Code" has no colon,
//     "PNR No:" has one) — the parser must trim after stripping colons.
//   • Departure time field is misspelled: "Depaturue Time" (original TNSTC typo).

/// Successful HTML response matching the real TNSTC layout for T82111889.
/// Phone 9566863531 matches → returns a valid TNSTCTicketModel.
/// Journey date is null because the API does not return it.
const String t82111889HtmlSuccess = '''
<!DOCTYPE html>
<html>
<head><title>Know Your Conductor - TNSTC</title></head>
<body>
<div class="container-fluid" style="font-size:12px">
  <!-- Row 1 -->
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">PNR No:</div>
    <div class="col-6 col-md-3 text-md-right">T82111889</div>
    <div class="col-6 col-md-3 font-weight-bold">Trip Code</div>
    <div class="col-6 col-md-3 text-md-right">2200CHEKUMLB</div>
  </div>
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Class Name:</div>
    <div class="col-6 col-md-3 text-md-right">NON AC LOWER BERTH SEATER</div>
    <div class="col-6 col-md-3 font-weight-bold">Corporation Code</div>
    <div class="col-6 col-md-3 text-md-right">SETC</div>
  </div>
  <!-- Row 2 -->
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">From Place Name:</div>
    <div class="col-6 col-md-3 text-md-right">CHENNAI-PT DR. M.G.R. BS</div>
    <div class="col-6 col-md-3 font-weight-bold">To Place name:</div>
    <div class="col-6 col-md-3 text-md-right">KUMBAKONAM</div>
  </div>
  <!-- Row 3 -->
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Passenger Name:</div>
    <div class="col-6 col-md-3 text-md-right">HarishAnbalagan</div>
    <div class="col-6 col-md-3 font-weight-bold">Mobile no</div>
    <div class="col-6 col-md-3 text-md-right">9566863531</div>
  </div>
  <!-- Total -->
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Booking Date:</div>
    <div class="col-6 col-md-3 text-md-right">10/06/2026</div>
    <div class="col-6 col-md-3 font-weight-bold">Seat No</div>
    <div class="col-6 col-md-3 text-md-right">,2LB</div>
  </div>
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Total Amount:</div>
    <div class="col-6 col-md-3 text-md-right"></div>
    <div class="col-6 col-md-3 font-weight-bold">Status</div>
    <div class="col-6 col-md-3 text-md-right">CONFIRMED</div>
  </div>
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Conductor Mobile No:</div>
    <div class="col-6 col-md-3 text-md-right">8072101877</div>
    <div class="col-6 col-md-3 font-weight-bold">Vehicle No</div>
    <div class="col-6 col-md-3 text-md-right">TN01AN4332</div>
  </div>
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Depaturue Time:</div>
    <div class="col-6 col-md-3 text-md-right">22:00:00</div>
    <div class="col-6 col-md-3 font-weight-bold">Journey Status</div>
    <div class="col-6 col-md-3 text-md-right">JOURNEY COMPLETED</div>
  </div>
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">PlatFORM No:</div>
    <div class="col-6 col-md-3 text-md-right">2</div>
    <div class="col-6 col-md-3 font-weight-bold"></div>
    <div class="col-6 col-md-3 text-md-right"></div>
  </div>
</div>
</body>
</html>
''';

/// HTML response where the phone number does NOT match — used to verify
/// the phone verification guard.
const String t82111889HtmlWrongPhone = '''
<!DOCTYPE html>
<html>
<head><title>Know Your Conductor - TNSTC</title></head>
<body>
<div class="container-fluid" style="font-size:12px">
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">PNR No:</div>
    <div class="col-6 col-md-3 text-md-right">T82111889</div>
    <div class="col-6 col-md-3 font-weight-bold">Trip Code</div>
    <div class="col-6 col-md-3 text-md-right">2200CHEKUMLB</div>
  </div>
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Passenger Name:</div>
    <div class="col-6 col-md-3 text-md-right">Someone Else</div>
    <div class="col-6 col-md-3 font-weight-bold">Mobile no</div>
    <div class="col-6 col-md-3 text-md-right">9999999999</div>
  </div>
</div>
</body>
</html>
''';

/// HTML error page returned when PNR is not found.
const String t82111889HtmlNotFound = '''
<!DOCTYPE html>
<html>
<head><title>Error Page</title></head>
<body>
<h1>Error Page</h1>
<p>Invalid PNR or ticket not found.</p>
</body>
</html>
''';

/// HTML response with no PNR No field (malformed / unexpected layout).
const String t82111889HtmlMissingPnr = '''
<!DOCTYPE html>
<html>
<head><title>Know Your Conductor - TNSTC</title></head>
<body>
<div class="container-fluid" style="font-size:12px">
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Booking Date:</div>
    <div class="col-6 col-md-3 text-md-right">10/06/2026</div>
    <div class="col-6 col-md-3 font-weight-bold">Mobile no</div>
    <div class="col-6 col-md-3 text-md-right">9566863531</div>
  </div>
</div>
</body>
</html>
''';

/// HTML response with seat number containing OCR-style artifacts (120B → 12UB).
const String t82111889HtmlOcrSeat = '''
<!DOCTYPE html>
<html>
<head><title>Know Your Conductor - TNSTC</title></head>
<body>
<div class="container-fluid" style="font-size:12px">
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">PNR No:</div>
    <div class="col-6 col-md-3 text-md-right">T82111889</div>
    <div class="col-6 col-md-3 font-weight-bold">Mobile no</div>
    <div class="col-6 col-md-3 text-md-right">9566863531</div>
  </div>
  <div class="row mb-2">
    <div class="col-6 col-md-3 font-weight-bold">Seat No</div>
    <div class="col-6 col-md-3 text-md-right">120B</div>
    <div class="col-6 col-md-3 font-weight-bold"></div>
    <div class="col-6 col-md-3 text-md-right"></div>
  </div>
</div>
</body>
</html>
''';
