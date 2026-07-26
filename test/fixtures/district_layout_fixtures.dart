// this is just fixtures and may contain more than 80 character

import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

import 'district/tdahhpy.dart' as tdahhpy_fixture;
import 'district/trahkmr.dart' as trahkmr_fixture;

/// Barrel class providing access to all District layout fixtures.
/// Each fixture is split into its own file under the district/ directory.
class DistrictLayoutFixtures {
  static final List<OCRBlock> trahkmr = trahkmr_fixture.trahkmr;
  static const Map<String, Object?> trahkmrExpected =
      trahkmr_fixture.trahkmrExpected;

  static final List<OCRBlock> tdahhpy = tdahhpy_fixture.tdahhpy;
  static const Map<String, Object?> tdahhpyExpected =
      tdahhpy_fixture.tdahhpyExpected;
}
