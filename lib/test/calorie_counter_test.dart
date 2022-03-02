import 'package:calorie_counter/utils/bmr_model.dart';
import 'package:calorie_counter/views/navigation/searchPage.dart';
import 'package:test/test.dart';

void main() {
  group('Calorie Counter', () {
    test('value should be 361', () {
      expect(HBO().calculate(0, 0, 0), 361);
    });

    test('appropriate model should be HBO', () {
      final model = getAppropriateModel(1, 1);
      expect(model.runtimeType == HBO().runtimeType, true);
    });

    test('daily calories should be 1579', () {
      expect(HBO.female().calculate(50, 160, 32), 1579);
    });
  });

  group('Barcode Validation', () {
    test('value should be false', () {
      expect(SearchPage.validBarcodeTest(""), false);
    });
    test('value should be false', () {
      expect(SearchPage.validBarcodeTest("9780"), false);
    });
    test('value should be false', () {
      expect(SearchPage.validBarcodeTest("abc"), false);
    });
    test('value should be false', () {
      expect(SearchPage.validBarcodeTest("9780aaaaaaaaa"), false);
    });
    test('value should be true', () {
      expect(SearchPage.validBarcodeTest("978020137962"), false);
    });
    test('value should be false', () {
      expect(SearchPage.validBarcodeTest("978020137960"), false);
    });
  });
}
