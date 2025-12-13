import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart' show getIt;
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:sqflite/sqflite.dart';

class StationPdfParser {
  factory StationPdfParser() => _instance;
  StationPdfParser._internal();

  static final StationPdfParser _instance = StationPdfParser._internal();

  late final IPDFService _pdfService;
  late final ILogger _logger;

  final IWalletDatabase _db = getIt<IWalletDatabase>();

  Future<void> init() async {
    _pdfService = getIt<IPDFService>();
    _logger = getIt<ILogger>();
    await _parseAndInsertIfRequired();
  }

  /// Call once on app startup
  Future<void> _parseAndInsertIfRequired() async {
    final database = await _db.database;

    // ---- CHECK IF TABLE IS EMPTY ----
    final countResult = await database.rawQuery(
      'SELECT COUNT(*) as count FROM stations',
    );
    final count = countResult.first['count']! as int;

    if (count > 0) {
      _logger.debug(
        '[StationPdfParser] stations table already populated, skipping',
      );
      return;
    }

    _logger.info('[StationPdfParser] Parsing station PDF');

    // ---- LOAD PDF FROM ASSETS ----
    final pdfFile = await loadPdfFromAssets('assets/pdf/station_codes.pdf');

    // ---- EXTRACT TEXT USING YOUR PDFService ----
    final text = await _pdfService.extractTextFrom(pdfFile);

    final stations = _parseStations(text);

    // ---- INSERT USING MAP ----
    final batch = database.batch();

    for (final station in stations) {
      batch.insert(
        'stations',
        station.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);

    _logger.info(
      '[StationPdfParser] Inserted ${stations.length} stations',
    );
  }

  // --------------------------------------------------
  // PARSING LOGIC
  // --------------------------------------------------
  List<_Station> _parseStations(String text) {
    final lines = text.split('\n');
    final result = <_Station>[];

    for (final line in lines) {
      final cleaned = line.trim();
      if (cleaned.isEmpty) continue;

      // Example: "KUMBAKONAM KMU"
      final match = RegExp(r'^(.+?)\s+([A-Z]{2,5})$').firstMatch(cleaned);

      if (match != null) {
        result.add(
          _Station(
            name: match.group(1)!.trim(),
            code: match.group(2)!.trim(),
          ),
        );
      }
    }
    return result;
  }

  Future<XFile> loadPdfFromAssets(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final dir = await getTemporaryDirectory();
    final file = File(join(dir.path, 'station_codes.pdf'));
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return XFile(file.path);
  }

  Future<String?> getStationName(String code) async {
    final db = await _db.database;
    final normalizedCode = code.toUpperCase();

    final result = await db.query(
      'stations',
      columns: ['station_name'],
      where: 'station_code = ?',
      whereArgs: [normalizedCode],
      limit: 1,
    );

    if (result.isEmpty) return code;

    final name = (result.first['station_name'] ?? code) as String;

    return name;
  }
}

class _Station {
  _Station({
    required this.name,
    required this.code,
  });

  final String name;
  final String code;

  Map<String, dynamic> toMap() {
    return {
      'station_name': name,
      'station_code': code,
    };
  }
}
