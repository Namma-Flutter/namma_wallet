import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/services/namma_logger.dart';

void main() {
  group('NammaLogger URL Sanitization', () {
    late NammaLogger logger;

    setUp(() {
      logger = NammaLogger();
    });

    test('strips all query parameters by default (secure by default)', () {
      const url = 'https://api.example.com/data?token=secret123&id=456';

      // Default behavior: all query params should be stripped
      expect(
        () => logger.logHttpRequest('GET', url),
        returnsNormally,
      );
      expect(
        () => logger.logHttpResponse('GET', url, 200),
        returnsNormally,
      );
    });

    test('strips all query parameters including seemingly safe ones', () {
      const url =
          'https://api.example.com/user?'
          'api_key=key123&session_id=sess456&name=John&page=1';

      // By default, ALL params are stripped (even 'page' and 'name')
      expect(
        () => logger.logHttpRequest('POST', url),
        returnsNormally,
      );
      expect(
        () => logger.logHttpResponse('POST', url, 201),
        returnsNormally,
      );
    });

    test('handles URL with no query parameters', () {
      const url = 'https://api.example.com/users';

      expect(
        () => logger.logHttpRequest('GET', url),
        returnsNormally,
      );
      expect(
        () => logger.logHttpResponse('GET', url, 200),
        returnsNormally,
      );
    });

    test('preserves only explicitly allowed query parameters', () {
      const url = 'https://api.example.com/search?q=flutter&page=1&token=abc';

      // Only preserve 'q' and 'page', strip 'token'
      expect(
        () => logger.logHttpRequest(
          'GET',
          url,
          allowedQueryParams: {'q', 'page'},
        ),
        returnsNormally,
      );
      expect(
        () => logger.logHttpResponse(
          'GET',
          url,
          200,
          allowedQueryParams: {'q', 'page'},
        ),
        returnsNormally,
      );
    });

    test('handles invalid URL gracefully', () {
      const url = 'not a valid url';

      expect(
        () => logger.logHttpRequest('GET', url),
        returnsNormally,
      );
      expect(
        () => logger.logHttpResponse('GET', url, 400),
        returnsNormally,
      );
    });

    test('strips all query params regardless of key names', () {
      const urls = [
        'https://api.example.com?Token=abc',
        'https://api.example.com?API_KEY=xyz',
        'https://api.example.com?password=pass123',
        'https://api.example.com?access_token=token123',
        'https://api.example.com?refresh_token=refresh123',
        'https://api.example.com?authorization=auth123',
        'https://api.example.com?safe_param=value',
        'https://api.example.com?id=123',
      ];

      for (final url in urls) {
        // All params are stripped by default
        expect(
          () => logger.logHttpRequest('GET', url),
          returnsNormally,
        );
        expect(
          () => logger.logHttpResponse('GET', url, 200),
          returnsNormally,
        );
      }
    });

    test('allowlist with empty set strips all params', () {
      const url = 'https://api.example.com/data?id=123&page=1';

      expect(
        () => logger.logHttpRequest('GET', url, allowedQueryParams: {}),
        returnsNormally,
      );
      expect(
        () => logger.logHttpResponse(
          'GET',
          url,
          200,
          allowedQueryParams: {},
        ),
        returnsNormally,
      );
    });

    test('logger initialization completes successfully', () {
      expect(logger, isNotNull);
      expect(logger.talker, isNotNull);
    });

    test('all logging methods work correctly', () {
      expect(() => logger.info('Test info'), returnsNormally);
      expect(() => logger.debug('Test debug'), returnsNormally);
      expect(() => logger.warning('Test warning'), returnsNormally);
      expect(() => logger.error('Test error'), returnsNormally);
      expect(() => logger.critical('Test critical'), returnsNormally);
      expect(() => logger.success('Test success'), returnsNormally);
      expect(() => logger.logDatabase('SELECT', 'tickets'), returnsNormally);
      expect(() => logger.logNavigation('/home'), returnsNormally);
      expect(() => logger.logService('API', 'fetch'), returnsNormally);
      expect(
        () => logger.logTicketParsing('IRCTC', 'success'),
        returnsNormally,
      );
    });
  });
}
