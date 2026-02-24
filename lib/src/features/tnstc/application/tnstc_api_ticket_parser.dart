import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

class TNSTCApiTicketParser {
  Ticket parse(TNSTCTicketModel model) {
    final normalizedTime = _normalizeServiceStartTime(model.serviceStartTime);
    final normalizedSeats = _normalizeSeatNumbers(model.smsSeatNumbers);

    final normalizedModel = model.copyWith(
      serviceStartTime: normalizedTime,
      smsSeatNumbers: normalizedSeats,
    );

    return Ticket.fromTNSTC(normalizedModel, sourceType: 'API');
  }

  String? _normalizeServiceStartTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return raw;

    final cleaned = raw
        .replaceAll(RegExp(r'\bhrs?\.?\b', caseSensitive: false), '')
        .trim();

    final match = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*$').firstMatch(
      cleaned,
    );
    if (match == null) return cleaned;

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);

    if (hour == null || minute == null) return cleaned;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return cleaned;

    final normalizedHour = hour.toString().padLeft(2, '0');
    final normalizedMinute = minute.toString().padLeft(2, '0');
    return '$normalizedHour:$normalizedMinute';
  }

  String? _normalizeSeatNumbers(String? raw) {
    if (raw == null || raw.trim().isEmpty) return raw;

    final normalized = raw
        .split(',')
        .map((seat) => seat.trim())
        .where((seat) => seat.isNotEmpty)
        .join(', ');

    return normalized.isEmpty ? null : normalized;
  }
}
