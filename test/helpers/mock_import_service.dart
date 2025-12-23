import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/features/import/application/import_service_interface.dart';

class MockImportService implements IImportService {
  MockImportService({this.mockTicket});

  final Ticket? mockTicket;
  final List<XFile> importedFiles = [];

  @override
  Future<Ticket?> importAndSavePDFFile(XFile pdfFile) async {
    return null;
  }

  @override
  Future<Ticket?> importAndSavePKPassFile(XFile pkpassFile) async {
    importedFiles.add(pkpassFile);
    return mockTicket;
  }

  @override
  Future<Ticket?> importQRCode(String qrData) async {
    return null;
  }

  @override
  bool isSupportedQRCode(String qrData) {
    return false;
  }

  @override
  List<String> get supportedExtensions => ['pdf', 'pkpass'];
}
