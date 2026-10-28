import 'package:intl/intl.dart';

/// Standard financial calculations and formatting for Filmytell Admin Portal.
/// Guaranteed 4-decimal precision as defined by Filmytell Revenue Report standards.
class FinancialFormatter {
  static final NumberFormat _currencyFormat4 = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 4,
    customPattern: '¤ #,##,##0.0000',
  );

  static final NumberFormat _currencyFormat2 = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    customPattern: '¤ #,##,##0.00',
  );

  /// Format as currency with 4 decimal places (e.g., ₹ 295.0000)
  static String format4(dynamic value) {
    if (value == null) return '₹ 0.0000';
    final numVal = _toNum(value);
    return _currencyFormat4.format(numVal);
  }

  /// Format as currency with 2 decimal places (if explicitly required for compact badges)
  static String format2(dynamic value) {
    if (value == null) return '₹ 0.00';
    final numVal = _toNum(value);
    return _currencyFormat2.format(numVal);
  }

  /// Format raw number to exactly 4 decimal places string (e.g., "295.0000")
  static String formatPlain4(dynamic value) {
    if (value == null) return '0.0000';
    final numVal = _toNum(value);
    return numVal.toStringAsFixed(4);
  }

  /// Format percentage to 2 or 4 decimal places
  static String formatPercent(dynamic value, {int decimals = 2}) {
    if (value == null) return '0%';
    final numVal = _toNum(value);
    return '${numVal.toStringAsFixed(decimals)}%';
  }

  static double _toNum(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) {
      final cleaned = val.replaceAll('₹', '').replaceAll(',', '').trim();
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  /// Calculation Helpers matching Filmytell Revenue Report Standard:
  
  /// Base Amount = Customer Payment / 1.18
  static double calculateBaseAmount(double customerPayment) {
    if (customerPayment <= 0) return 0.0;
    return customerPayment / 1.18;
  }

  /// GST Amount = Customer Payment - Base Amount
  static double calculateGst(double customerPayment) {
    if (customerPayment <= 0) return 0.0;
    return customerPayment - calculateBaseAmount(customerPayment);
  }

  /// Payment Gateway / Platform Charges = Customer Payment * 2%
  static double calculateGatewayFee(double customerPayment, {double rate = 0.02}) {
    if (customerPayment <= 0) return 0.0;
    return customerPayment * rate;
  }

  /// Net Revenue = Base Amount - Gateway Fee
  static double calculateNetRevenue(double customerPayment, {double gatewayRate = 0.02}) {
    final base = calculateBaseAmount(customerPayment);
    final gateway = calculateGatewayFee(customerPayment, rate: gatewayRate);
    return (base - gateway).clamp(0.0, double.infinity);
  }

  /// Platform Revenue = Net Revenue * 30%
  static double calculatePlatformRevenue(double netRevenue, {double rate = 0.30}) {
    return netRevenue * rate;
  }

  /// Production House Gross Revenue = Net Revenue * 70%
  static double calculateProductionGrossRevenue(double netRevenue, {double rate = 0.70}) {
    return netRevenue * rate;
  }

  /// Production TDS = Production Gross Revenue * 10%
  static double calculateProductionTds(double productionGrossRevenue, {double tdsRate = 0.10}) {
    return productionGrossRevenue * tdsRate;
  }

  /// Production Payout Fee = Production Gross Revenue * 2%
  static double calculateProductionPayoutCharge(double productionGrossRevenue, {double payoutRate = 0.02}) {
    return productionGrossRevenue * payoutRate;
  }

  /// Final Production House Revenue = Production Gross - TDS - Payout Charge
  static double calculateFinalProductionRevenue(double productionGrossRevenue) {
    final tds = calculateProductionTds(productionGrossRevenue);
    final payout = calculateProductionPayoutCharge(productionGrossRevenue);
    return (productionGrossRevenue - tds - payout).clamp(0.0, double.infinity);
  }

  /// Promoter Revenue = Base Amount * (Promoter Rate % / 100)
  static double calculatePromoterRevenue(double customerPayment, double promoterRatePercent) {
    final base = calculateBaseAmount(customerPayment);
    final rate = promoterRatePercent > 1.0 ? promoterRatePercent / 100.0 : promoterRatePercent;
    return base * rate;
  }

  /// Promoter rate percentage based on tier level
  static double getPromoterRate(String? level) {
    switch (level?.toLowerCase().trim()) {
      case 'national':
        return 2.0;
      case 'state':
        return 1.5;
      case 'district':
        return 1.0;
      case 'taluka':
        return 0.5;
      default:
        return 1.0;
    }
  }
}
