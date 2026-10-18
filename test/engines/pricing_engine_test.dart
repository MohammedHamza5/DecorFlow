import 'package:flutter_test/flutter_test.dart';
import 'package:stream_pay/engines/pricing/models/price_models.dart';
import 'package:stream_pay/engines/pricing/pricing_engine.dart';

void main() {
  group('PricingEngine', () {
    late PricingEngine engine;

    setUp(() {
      engine = PricingEngine();
    });

    test('Basic pricing without discounts or accessories', () {
      final input = PriceInput(
        quantity: 10,
        unitLabel: 'قطعة',
        listPrice: 50.0,
      );

      final result = engine.calculatePrice(input);

      expect(result.listPrice, 50.0);
      expect(result.netUnitPrice, 50.0);
      expect(result.totalBeforeDiscount, 500.0);
      expect(result.totalDiscount, 0.0);
      expect(result.finalTotal, 500.0);
    });

    test('Percentage discount applied correctly', () {
      final input = PriceInput(
        quantity: 10,
        unitLabel: 'قطعة',
        listPrice: 100.0,
        discounts: [
          Discount(name: 'Trade Discount', value: 0.10, isPercentage: true),
        ],
      );

      final result = engine.calculatePrice(input);

      expect(result.netUnitPrice, 90.0);
      expect(result.totalBeforeDiscount, 1000.0);
      expect(result.totalDiscount, 100.0);
      expect(result.subtotalAfterDiscount, 900.0);
      expect(result.finalTotal, 900.0);
      expect(result.discountBreakdown.length, 1);
      expect(result.discountBreakdown[0].discountAmount, 10.0); // Per unit discount
    });

    test('Sequential discounts applied correctly', () {
      final input = PriceInput(
        quantity: 1,
        unitLabel: 'قطعة',
        listPrice: 100.0,
        discounts: [
          Discount(name: 'Trade', value: 0.10, isPercentage: true), // 10% off 100 = 90
          Discount(name: 'Cash', value: 0.05, isPercentage: true), // 5% off 90 = 85.5
          Discount(name: 'Promo', value: 5.5, isPercentage: false), // 85.5 - 5.5 = 80
        ],
      );

      final result = engine.calculatePrice(input);

      expect(result.netUnitPrice, 80.0);
      expect(result.totalDiscount, 20.0);
      expect(result.finalTotal, 80.0);
      expect(result.discountBreakdown.length, 3);
      expect(result.discountBreakdown[0].afterPrice, 90.0);
      expect(result.discountBreakdown[1].afterPrice, 85.5);
      expect(result.discountBreakdown[2].afterPrice, 80.0);
    });

    test('Expired discounts are ignored', () {
      final input = PriceInput(
        quantity: 1,
        unitLabel: 'قطعة',
        listPrice: 100.0,
        discounts: [
          Discount(
            name: 'Expired Promo',
            value: 0.50,
            isPercentage: true,
            validUntil: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      );

      final result = engine.calculatePrice(input);

      expect(result.netUnitPrice, 100.0);
      expect(result.totalDiscount, 0.0);
      expect(result.discountBreakdown.length, 0);
    });

    test('Accessories and installation added correctly', () {
      final input = PriceInput(
        quantity: 5,
        unitLabel: 'قطعة',
        listPrice: 100.0,
        installationRate: 20.0, // 20 per unit = 100
        accessories: [
          AccessoryPrice(name: 'Glue', quantity: 2, unitPrice: 50.0), // 100
          AccessoryPrice(name: 'Clips', quantity: 1, unitPrice: 30.0), // 30
        ],
      );

      final result = engine.calculatePrice(input);

      expect(result.subtotalAfterDiscount, 500.0); // 5 * 100
      expect(result.installationCost, 100.0); // 5 * 20
      expect(result.accessoriesCost, 130.0); // 100 + 30
      expect(result.finalTotal, 730.0); // 500 + 100 + 130
    });

    test('Profit margin applied correctly', () {
      final input = PriceInput(
        quantity: 1,
        unitLabel: 'متر',
        listPrice: 1000.0,
        profitMargin: 0.20, // 20%
      );

      final result = engine.calculatePrice(input);

      expect(result.subtotalAfterDiscount, 1000.0);
      expect(result.profitAmount, 200.0);
      expect(result.finalTotal, 1200.0);
    });

    test('quickPrice method', () {
      final price = engine.quickPrice(
        quantity: 2,
        listPrice: 100.0,
        discounts: [
          Discount(name: '10%', value: 0.10, isPercentage: true),
        ],
      );

      // (100 * 0.9) * 2 = 180
      expect(price, 180.0);
    });
  });
}
