import 'dart:typed_data';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';

// More methods will be added in the future
// ignore: one_member_abstracts
abstract interface class IPKPassParser {
  /// Parses a pkpass file content and returns a Ticket.
  Future<Ticket?> parsePKPass(Uint8List data);
}
