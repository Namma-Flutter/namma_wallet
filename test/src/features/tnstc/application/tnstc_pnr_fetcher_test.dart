// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:namma_wallet/src/features/tnstc/data/remote/tnstc_pnr_fetcher.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

import '../../../../fixtures/tnstc/t82111889_html.dart';
import '../../../../helpers/fake_logger.dart';

// ---------------------------------------------------------------------------
// Helper: builds a MockClient that returns a fixed HTML form page (GET) and
// then the provided [responseHtml] for the POST lookup request.
// ---------------------------------------------------------------------------
MockClient _mockClientWith({
  required String responseHtml,
  int formStatusCode = 200,
  int submitStatusCode = 200,
}) {
  return MockClient((request) async {
    if (request.method == 'GET') {
      return http.Response(
        '<html><body>'
        '<form action="/OTRSOnline/manageKnowYourConductor.do;jsessionid=AABBCC"></form>'
        '</body></html>',
        formStatusCode,
      );
    }
    // POST — return the ticket lookup HTML
    return http.Response(responseHtml, submitStatusCode);
  });
}

void main() {
  late FakeLogger fakeLogger;
  late TNSTCPNRFetcher fetcher;

  const pnr = 'T82111889';
  const phone = '9566863531';

  setUp(() {
    fakeLogger = FakeLogger();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Reality check: what the TNSTC API actually returns
  //
  // Verified by live fetch on 22/06/2026:
  //   • NO Journey Date field exists — journeyDate is always null from API
  //   • Booking Date (10/06/2026) is the PURCHASE date, not the travel date
  //   • Phone field label is "Mobile no" (lowercase "no")
  //   • Rows have 4 cols (label, value, label, value) using col-6 col-md-3
  //   • Departure time field: "Depaturue Time" (TNSTC typo, preserved)
  // ─────────────────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────────────────
  // Group 1: parseHtmlResponseForTesting — unit-tests the HTML parser
  //          directly without any network I/O.
  // ─────────────────────────────────────────────────────────────────────────
  group('TNSTCPNRFetcher.parseHtmlResponseForTesting', () {
    setUp(() {
      fetcher = TNSTCPNRFetcher(logger: fakeLogger);
    });

    test('parses success HTML and returns a TNSTCTicketModel', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        phone,
      );

      expect(result, isNotNull);
      expect(result!.pnrNumber, equals('T82111889'));
    });

    test('returns correct journey metadata from success HTML', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        phone,
      );

      expect(result, isNotNull);
      expect(result!.corporation, equals('SETC'));
      expect(result.serviceStartPlace, equals('CHENNAI-PT DR. M.G.R. BS'));
      expect(result.serviceEndPlace, equals('KUMBAKONAM'));
      expect(result.classOfService, equals('NON AC LOWER BERTH SEATER'));
      expect(result.tripCode, equals('2200CHEKUMLB'));
    });

    // ── Journey date: API does NOT return one ────────────────────────────
    test(
      'journeyDate is null — TNSTC API does not return a Journey Date field',
      () {
        final result = fetcher.parseHtmlResponseForTesting(
          t82111889HtmlSuccess,
          pnr,
          phone,
        );

        expect(result, isNotNull);
        // The API only returns "Booking Date" (purchase date = 10/06/2026).
        // The journey travel date is NOT in the API response.
        expect(result!.journeyDate, isNull);
      },
    );

    test(
      'does NOT treat Booking Date (10/06/2026) as journey date',
      () {
        final result = fetcher.parseHtmlResponseForTesting(
          t82111889HtmlSuccess,
          pnr,
          phone,
        );

        expect(result, isNotNull);
        // Booking Date = 10/06/2026 is the purchase date — must never be day 10.
        expect(result!.journeyDate?.day, isNot(10));
      },
    );

    // ── Departure time ───────────────────────────────────────────────────
    test('parses departure time from "Depaturue Time" (TNSTC typo)', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        phone,
      );

      expect(result, isNotNull);
      // Raw value is "22:00:00"; TNSTCApiTicketParser normalises to "22:00"
      expect(result!.serviceStartTime, equals('22:00:00'));
    });

    // ── Passenger & phone ────────────────────────────────────────────────
    test('parses passenger name from "Passenger Name" field', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        phone,
      );

      expect(result, isNotNull);
      expect(result!.passengers, hasLength(1));
      expect(result.passengers.first.name, equals('HarishAnbalagan'));
    });

    test(
      'verifies phone using "Mobile no" (lowercase "no") field label',
      () {
        // If the phone field label normalisation is broken, this returns null.
        final result = fetcher.parseHtmlResponseForTesting(
          t82111889HtmlSuccess,
          pnr,
          phone,
        );

        expect(result, isNotNull,
            reason: '"Mobile no" label must match via key normalisation');
      },
    );

    // ── Seat number ──────────────────────────────────────────────────────
    test('strips leading comma from seat number ",2LB" → "2LB"', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        phone,
      );

      expect(result, isNotNull);
      // Raw value is ",2LB"; _normalizeSeatNumbers splits on comma, trims.
      expect(result!.smsSeatNumbers, equals('2LB'));
    });

    // ── Conductor & vehicle ──────────────────────────────────────────────
    test('parses conductor mobile number', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        phone,
      );

      expect(result, isNotNull);
      expect(result!.conductorMobileNo, equals('8072101877'));
    });

    test('parses vehicle number', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        phone,
      );

      expect(result, isNotNull);
      expect(result!.vehicleNumber, equals('TN01AN4332'));
    });

    // ── Phone verification guard ─────────────────────────────────────────
    test('returns null when phone number does not match', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlWrongPhone,
        pnr,
        phone, // '9566863531' ≠ '9999999999' in fixture
      );

      expect(result, isNull);
      expect(
        fakeLogger.logs,
        anyElement(contains('Phone verification failed')),
      );
    });

    test('returns null for error page HTML', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlNotFound,
        pnr,
        phone,
      );

      expect(result, isNull);
    });

    test('returns null when PNR No field is absent in HTML', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlMissingPnr,
        pnr,
        phone,
      );

      expect(result, isNull);
      expect(
        fakeLogger.logs,
        anyElement(contains('Parsed response missing PNR No')),
      );
    });

    test('normalises OCR-corrupted seat "120B" to "12UB"', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlOcrSeat,
        pnr,
        phone,
      );

      expect(result, isNotNull);
      expect(result!.smsSeatNumbers, equals('12UB'));
    });

    // ── Phone normalisation edge-cases ───────────────────────────────────
    test('matches phone with leading +91 country code', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        '+919566863531',
      );

      expect(result, isNotNull);
    });

    test('matches phone with dashes in input', () {
      final result = fetcher.parseHtmlResponseForTesting(
        t82111889HtmlSuccess,
        pnr,
        '956-686-3531',
      );

      expect(result, isNotNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Group 2: fetchTicketByPNR — full-stack mock (MockClient intercepts HTTP)
  // ─────────────────────────────────────────────────────────────────────────
  group('TNSTCPNRFetcher.fetchTicketByPNR (MockClient)', () {
    test('returns TNSTCTicketModel on success', () async {
      fetcher = TNSTCPNRFetcher(
        logger: fakeLogger,
        httpClient: _mockClientWith(responseHtml: t82111889HtmlSuccess),
      );

      final result = await fetcher.fetchTicketByPNR(pnr, phone);

      expect(result, isA<TNSTCTicketModel>());
      expect(result!.pnrNumber, equals('T82111889'));
    });

    test('returns null when phone mismatch in API response', () async {
      fetcher = TNSTCPNRFetcher(
        logger: fakeLogger,
        httpClient: _mockClientWith(responseHtml: t82111889HtmlWrongPhone),
      );

      final result = await fetcher.fetchTicketByPNR(pnr, phone);

      expect(result, isNull);
    });

    test('returns null when server returns a non-200 form page', () async {
      fetcher = TNSTCPNRFetcher(
        logger: fakeLogger,
        httpClient: _mockClientWith(
          responseHtml: t82111889HtmlSuccess,
          formStatusCode: 503,
        ),
      );

      final result = await fetcher.fetchTicketByPNR(pnr, phone);

      expect(result, isNull);
    });

    test('returns null when submit endpoint returns non-200', () async {
      fetcher = TNSTCPNRFetcher(
        logger: fakeLogger,
        httpClient: _mockClientWith(
          responseHtml: t82111889HtmlSuccess,
          submitStatusCode: 500,
        ),
      );

      final result = await fetcher.fetchTicketByPNR(pnr, phone);

      expect(result, isNull);
    });

    test('returns null for empty PNR', () async {
      fetcher = TNSTCPNRFetcher(
        logger: fakeLogger,
        httpClient: _mockClientWith(responseHtml: t82111889HtmlSuccess),
      );

      final result = await fetcher.fetchTicketByPNR('', phone);

      expect(result, isNull);
      expect(fakeLogger.logs, anyElement(contains('PNR is empty')));
    });

    test('returns null for empty phone number', () async {
      fetcher = TNSTCPNRFetcher(
        logger: fakeLogger,
        httpClient: _mockClientWith(responseHtml: t82111889HtmlSuccess),
      );

      final result = await fetcher.fetchTicketByPNR(pnr, '');

      expect(result, isNull);
      expect(fakeLogger.logs, anyElement(contains('Phone number is empty')));
    });

    test('returns null when server returns error page HTML', () async {
      fetcher = TNSTCPNRFetcher(
        logger: fakeLogger,
        httpClient: _mockClientWith(responseHtml: t82111889HtmlNotFound),
      );

      final result = await fetcher.fetchTicketByPNR(pnr, phone);

      expect(result, isNull);
    });

    test('never throws — returns null on network exception', () async {
      final throwingClient = MockClient((_) async => throw Exception('timeout'));

      fetcher = TNSTCPNRFetcher(
        logger: fakeLogger,
        httpClient: throwingClient,
      );

      expect(
        () => fetcher.fetchTicketByPNR(pnr, phone),
        returnsNormally,
      );
    });
  });
}
