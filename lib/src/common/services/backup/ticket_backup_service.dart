import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:namma_wallet/src/common/database/proto/namma_wallet.pb.dart';
import 'package:namma_wallet/src/common/database/ticket_backup_interface.dart';
import 'package:namma_wallet/src/common/services/backup/ticket_backup_service_interface.dart';

class TicketBackupService implements ITicketBackupService {
  TicketBackupService(this._dao);

  final ITicketBackupDao _dao;

  // CREATE BACKUP
    @override
  Future<String?> createBackup() async {
    final tickets = await _dao.fetchAllTickets();

    final backup = TicketBackup()
      ..schemaVersion = 1
      ..tickets.addAll(tickets);

    final protoBytes = backup.writeToBuffer();
    final gzipBytes = const GZipEncoder().encode(protoBytes);

    return FilePicker.platform.saveFile(
      dialogTitle: 'Save Backup',
      fileName: _generateBackupFileName(),
      type: FileType.custom,
      allowedExtensions: ['gz'],
      bytes: Uint8List.fromList(gzipBytes),
    );
  }

  // RESTORE BACKUP
  @override
  Future<bool> restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Backup File',
      type: FileType.custom,
      allowedExtensions: ['gz'],
    );

    if (result == null || result.files.single.path == null) {
      return false;
    }

    try {
      final file = File(result.files.single.path!);
      final gzipBytes = await file.readAsBytes();
      final protoBytes = const GZipDecoder().decodeBytes(gzipBytes);

      final backup = TicketBackup.fromBuffer(protoBytes);

      if (backup.schemaVersion != 1) {
        throw Exception('Unsupported backup version');
      }

      await _dao.restoreTickets(backup.tickets);
      return true;
    } on Exception catch (_)  {
      return false;
    }
  }

  String _generateBackupFileName() {
    final now = DateTime.now();
    return 'namma_wallet_${now.toIso8601String()}.proto.gz';
  }
}
