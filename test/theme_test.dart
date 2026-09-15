import 'package:flutter_test/flutter_test.dart';
import 'package:dripvision/core/theme.dart';

void main() {
  test('DripVision theme keeps teal as primary brand accent', () {
    expect(DripTheme.cosmicTeal.value, 0xFF00D4AA);
    expect(DripTheme.theme.colorScheme.primary, DripTheme.cosmicTeal);
  });
}
