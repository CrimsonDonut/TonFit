import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/heatmap.dart';

void main() {
  test('tiers by set count', () {
    expect(Heatmap.tier(0), equals(0));
    expect(Heatmap.tier(1), equals(1));
    expect(Heatmap.tier(6), equals(1));
    expect(Heatmap.tier(7), equals(2));
    expect(Heatmap.tier(12), equals(2));
    expect(Heatmap.tier(13), equals(3));
    expect(Heatmap.tier(18), equals(3));
    expect(Heatmap.tier(19), equals(4));
    expect(Heatmap.tier(60), equals(4));
  });
}
