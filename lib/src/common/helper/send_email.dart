import 'package:url_launcher/url_launcher.dart';

class EmailHelper {
  static Future<void> sendEmail({
    String subject = '',
    String body = '',
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@nammawallet.com',
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    if (!await launchUrl(emailUri)) {
      throw 'Could not launch $emailUri';
    }
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}