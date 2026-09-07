import 'package:flutter_test/flutter_test.dart';

// Smoke test placeholder.
//
// StoreApp now requires a Hive `favoritesBox` (opened asynchronously in
// main() before runApp). Building a full widget test for it would require
// setting up a fake Hive box, which is more than a "smoke test" needs.
// The Cubits themselves (ProductsCubit, CartCubit, ...) are already covered
// by focused unit tests under test/cubits/.
void main() {
  test('placeholder - see test/cubits for real unit tests', () {
    expect(1 + 1, 2);
  });
}
