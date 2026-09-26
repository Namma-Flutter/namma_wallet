import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

import 'konfhub/devfest_2025.dart' as devfest2025_fixture;
import 'konfhub/devfest_2026.dart' as devfest2026_fixture;
import 'konfhub/flutter_south_india_2026.dart'
    as flutter_south_india_2026_fixture;

class KonfHubLayoutFixtures {
  static final List<OCRBlock> devfest2025 = devfest2025_fixture.devfest2025;
  static const Map<String, Object?> devfest2025Expected =
      devfest2025_fixture.devfest2025Expected;

  static final List<OCRBlock> devfest2026 = devfest2026_fixture.sampleOCRBlocks;
  static const Map<String, Object?> devfest2026Expected =
      devfest2026_fixture.devfest2026Expected;

  static final List<OCRBlock> flutterSouthIndia2026 =
      flutter_south_india_2026_fixture.sampleOCRBlocks;
  static const Map<String, Object?> flutterSouthIndia2026Expected =
      flutter_south_india_2026_fixture.flutterSouthIndia2026Expected;
}
