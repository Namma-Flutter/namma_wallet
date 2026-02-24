import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pnr_fetcher_interface.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

/// Implementation of TNSTC PNR fetcher service.
///
/// This service fetches ticket details from the TNSTC website by:
/// 1. Establishing a session with the TNSTC server
/// 2. Submitting a PNR lookup request
/// 3. Parsing the HTML response to extract ticket information
///
/// **Error Handling:**
/// - Never throws exceptions
/// - Returns null on any error (network, parsing, invalid PNR)
/// - Logs all errors internally using ILogger
class TNSTCPNRFetcher implements ITNSTCPNRFetcher {
  TNSTCPNRFetcher({required ILogger logger}) : _logger = logger;

  final ILogger _logger;

  static const String _baseUrl = 'https://www.tnstc.in/OTRSOnline';
  static const String _formUrl = '$_baseUrl/preKnowYourConductor.do';
  static const String _submitUrl = '$_baseUrl/manageKnowYourConductor.do';

  @override
  Future<TNSTCTicketModel?> fetchTicketByPNR(
    String pnr,
    String phoneNumber,
  ) async {
    try {
      _logger.info('Fetching TNSTC ticket for PNR: $pnr');

      final pnrTrimmed = pnr.trim();
      final phoneTrimmed = phoneNumber.trim();
      if (pnrTrimmed.isEmpty) {
        _logger.warning('PNR is empty');
        return null;
      }
      if (phoneTrimmed.isEmpty) {
        _logger.warning('Phone number is empty');
        return null;
      }

      // Step 1: Establish session by visiting the form page
      final client = http.Client();
      try {
        _logger.logHttpRequest('GET', _formUrl);
        final formResponse = await client.get(Uri.parse(_formUrl));
        _logger.logHttpResponse('GET', _formUrl, formResponse.statusCode);

        if (formResponse.statusCode != 200) {
          _logger.error(
            'Failed to load form page: ${formResponse.statusCode}',
          );
          return null;
        }

        // Extract jsessionid from form page
        final jsessionId = _extractJSessionId(formResponse.body);
        final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

        // Step 2: Submit PNR lookup request
        final submitUrlWithSession = jsessionId != null
            ? '$_submitUrl;jsessionid=$jsessionId'
            : _submitUrl;

        _logger.logHttpRequest('POST', submitUrlWithSession);
        final response = await client.post(
          Uri.parse(submitUrlWithSession),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Referer': _formUrl,
          },
          body: {
            'hiddenAction': 'GetPnrDetails',
            'radViewType': 'P',
            'txtPnrId': pnrTrimmed,
            'txtEmailId': '',
            'txtMobileNo': '',
            'txtFromDate': currentDate,
          },
        );
        _logger.logHttpResponse(
          'POST',
          submitUrlWithSession,
          response.statusCode,
        );

        if (response.statusCode != 200) {
          _logger.error('PNR lookup failed: ${response.statusCode}');
          return null;
        }

        // Step 3: Parse HTML response
        final ticket = _parseHtmlResponse(
          response.body,
          pnrTrimmed,
          phoneTrimmed,
        );
        if (ticket != null) {
          _logger.success('Successfully fetched ticket for PNR: $pnr');
        } else {
          _logger.warning('No ticket data found for PNR: $pnr');
        }
        return ticket;
      } finally {
        client.close();
      }
    } on Exception catch (e, stackTrace) {
      _logger.error('Error fetching PNR: $pnr', e, stackTrace);
      return null;
    }
  }

  /// Extracts jsessionid from HTML content
  String? _extractJSessionId(String html) {
    final match = RegExp('jsessionid=([A-F0-9]+)').firstMatch(html);
    return match?.group(1);
  }

  /// Parses HTML response and extracts ticket information
  TNSTCTicketModel? _parseHtmlResponse(
    String html,
    String pnr,
    String phoneNumber,
  ) {
    try {
      final document = html_parser.parse(html);

      // Check if it's an error page
      if (html.contains('Error Page') || html.contains('Page Not Found')) {
        _logger.warning('Received error page for PNR: $pnr');
        return null;
      }

      // Extract ticket data from HTML
      final data = _extractTicketData(document);

      // Validate that we have essential data
      if (data.isEmpty) {
        _logger.warning('No ticket data found in HTML for PNR: $pnr');
        return null;
      }

      final apiPhoneNumber = _extractPassengerPhoneNumber(data);
      if (apiPhoneNumber == null) {
        _logger.warning('Passenger phone number not found for PNR: $pnr');
        return null;
      }

      final normalizedInputPhone = _normalizePhone(phoneNumber);
      final normalizedApiPhone = _normalizePhone(apiPhoneNumber);

      if (normalizedInputPhone.isEmpty ||
          normalizedApiPhone.isEmpty ||
          normalizedInputPhone != normalizedApiPhone) {
        _logger.warning('Phone verification failed for PNR: $pnr');
        return null;
      }

      // Parse journey date
      DateTime? journeyDate;
      final bookingDateStr = data['Booking Date'];
      if (bookingDateStr != null && bookingDateStr.isNotEmpty) {
        try {
          journeyDate = DateFormat('dd/MM/yyyy').parse(bookingDateStr);
        } on FormatException catch (e) {
          _logger.warning('Failed to parse journey date: $bookingDateStr - $e');
        }
      }

      return TNSTCTicketModel(
        pnrNumber: data['PNR No'] ?? pnr,
        tripCode: data['Trip Code'],
        corporation: data['Corporation Code'],
        serviceStartPlace: data['From Place Name'],
        serviceEndPlace: data['To Place name'],
        classOfService: data['Class Name'],
        journeyDate: journeyDate,
        serviceStartTime: data['Depaturue Time'],
        boardingPoint: data['Passenger Pickup Point'] ?? data['Boarding Point'],
        passengers: () {
          final passengerName = data['Passenger Name']?.trim();
          if (passengerName == null || passengerName.isEmpty) {
            return const <PassengerInfo>[];
          }
          return <PassengerInfo>[PassengerInfo(name: passengerName)];
        }(),
        smsSeatNumbers: data['Seat No'],
        conductorMobileNo: data['Conductor Mobile No'],
        vehicleNumber: data['Vehicle No'],
      );
    } on Exception catch (e, stackTrace) {
      _logger.error('Error parsing HTML response', e, stackTrace);
      return null;
    }
  }

  /// Extracts ticket data from HTML document using the table structure
  Map<String, String> _extractTicketData(Document document) {
    final data = <String, String>{};

    try {
      // The ticket data is in a container-fluid div with rows
      final rows = document.querySelectorAll('.container-fluid .row');

      for (final row in rows) {
        // Each row has label (font-weight-bold) and value pairs
        final cols = row.querySelectorAll('.col-6, .col-md-3');

        for (var i = 0; i < cols.length - 1; i += 2) {
          final label = cols[i].text.trim().replaceAll(':', '');
          final value = cols[i + 1].text.trim();

          if (label.isNotEmpty && value.isNotEmpty) {
            data[label] = value;
          }
        }
      }
    } on Exception catch (e) {
      _logger.warning('Error extracting ticket data from HTML: $e');
    }

    return data;
  }

  String? _extractPassengerPhoneNumber(Map<String, String> data) {
    const candidateKeys = <String>{
      'mobileno',
      'mobilenumber',
      'passengermobileno',
      'passengermobilenumber',
      'phoneno',
      'phonenumber',
      'contactnumber',
    };

    for (final entry in data.entries) {
      final normalizedKey = entry.key.toLowerCase().replaceAll(
        RegExp('[^a-z0-9]'),
        '',
      );
      if (!candidateKeys.contains(normalizedKey)) {
        continue;
      }

      // Safety: never treat conductor phone as passenger phone.
      if (normalizedKey.contains('conductor')) {
        continue;
      }

      final value = entry.value.trim();
      if (value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String _normalizePhone(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 10) {
      return digitsOnly.substring(digitsOnly.length - 10);
    }
    return digitsOnly;
  }
}
