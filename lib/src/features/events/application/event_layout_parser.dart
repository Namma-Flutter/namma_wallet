import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

abstract class EventLayoutParser {
  bool canParse(String text);

  /// Parse ticket from OCR blocks
  Future<Ticket?> parseTicketFromBlocks(
    List<OCRBlock> blocks,
    String imagePath,
  );

  String get providerName;
}
