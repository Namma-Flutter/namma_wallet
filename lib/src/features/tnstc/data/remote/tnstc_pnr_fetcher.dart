// coverage:ignore-file
// Network integration glue — exercised via integration tests.
import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' show MockClient;
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/data/remote/tnstc_pnr_fetcher_interface.dart';
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
  TNSTCPNRFetcher({required this._logger, this._httpClient});

  final ILogger _logger;

  /// Optional injected HTTP client. When null, a fresh [http.Client] is
  /// created per request. Inject a [MockClient] in tests.
  final http.Client? _httpClient;

  static const String _baseUrl = 'https://www.tnstc.in/OTRSOnline';
  static const String _formUrl = '$_baseUrl/preKnowYourConductor.do';
  static const String _submitUrl = '$_baseUrl/manageKnowYourConductor.do';
  static const Duration _requestTimeout = Duration(seconds: 15);

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
      final client = _httpClient ?? http.Client();
      final ownsClient = _httpClient == null;
      try {
        _logger.logHttpRequest('GET', _formUrl);
        http.Response formResponse;
        try {
          formResponse = await client
              .get(Uri.parse(_formUrl))
              .timeout(_requestTimeout);
        } on TimeoutException catch (e, stackTrace) {
          _logger.error('Timed out loading TNSTC form page', e, stackTrace);
          return null;
        }
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
        http.Response response;
        try {
          response = await client
              .post(
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
              )
              .timeout(_requestTimeout);
        } on TimeoutException catch (e, stackTrace) {
          _logger.error('Timed out submitting TNSTC PNR lookup', e, stackTrace);
          return null;
        }
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
        // Only close the client if we created it; injected clients are managed
        // by the caller.
        if (ownsClient) client.close();
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

  /// Parses HTML response and extracts ticket information.
  ///
  /// Exposed for unit-testing via HTML fixtures.
  @visibleForTesting
  TNSTCTicketModel? parseHtmlResponseForTesting(
    String html,
    String pnr,
    String phoneNumber,
  ) => _parseHtmlResponse(html, pnr, phoneNumber);

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

      final parsedPnr = data['PNR No']?.trim();
      if (parsedPnr == null || parsedPnr.isEmpty) {
        _logger.warning('Parsed response missing PNR No for input PNR: $pnr');
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

      // Parse journey date — prefer the travel date over the booking date.
      // The TNSTC response labels the travel date as "Journey Date"; some
      // response variants label it "Date of Journey". "Booking Date" is the
      // ticket-purchase date and must NOT be used as the journey date.
      DateTime? journeyDate;
      final journeyDateStr = data['Journey Date'] ?? data['Date of Journey'];
      if (journeyDateStr != null && journeyDateStr.isNotEmpty) {
        try {
          journeyDate = DateFormat('dd/MM/yyyy').parse(journeyDateStr);
        } on FormatException catch (e) {
          _logger.warning(
            'Failed to parse journey date: $journeyDateStr - $e',
          );
        }
      }

      return TNSTCTicketModel(
        pnrNumber: parsedPnr,
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
        smsSeatNumbers: _normalizeSeatNumbers(data['Seat No']),
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
          final label = cols[i].text.trim().replaceAll(':', '').trim();
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

  String? _normalizeSeatNumbers(String? rawSeats) {
    if (rawSeats == null || rawSeats.trim().isEmpty) {
      return rawSeats;
    }

    final normalized = rawSeats
        .split(',')
        .map((seat) => seat.trim())
        .map(
          (seat) => seat.replaceAllMapped(
            RegExp(r'(\d+)0B$'),
            (m) => '${m.group(1)}UB',
          ),
        )
        .map(
          (seat) => seat.replaceAllMapped(
            RegExp(r'(\d+)0L$'),
            (m) => '${m.group(1)}UL',
          ),
        )
        .where((seat) => seat.isNotEmpty)
        .join(', ');

    return normalized.isEmpty ? null : normalized;
  }
}
