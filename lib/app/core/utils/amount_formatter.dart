/// Central utility to format monetary amounts and currency without rounding or truncating API decimals.
String formatAmount(
  dynamic value, {
  String prefix = '',
  String defaultIfNull = '-',
  bool preserveStrings = true,
}) {
  if (value == null) return defaultIfNull;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return defaultIfNull;
    if (preserveStrings) {
      // If already starts with prefix or currency symbol, return as is
      if (prefix.isNotEmpty && trimmed.startsWith(prefix.trim())) {
        return trimmed;
      }
      return '$prefix$trimmed';
    }
    final parsed = num.tryParse(trimmed);
    if (parsed == null) return '$prefix$trimmed';
    value = parsed;
  }
  if (value is num) {
    if (value % 1 == 0) {
      return '$prefix${value.toInt()}';
    }
    return '$prefix$value';
  }
  return '$prefix$value';
}

String formatCurrency(
  dynamic value, {
  String prefix = 'Rs. ',
  String defaultIfNull = 'Rs. 0',
}) {
  if (value == null) return defaultIfNull;
  return formatAmount(value, prefix: prefix, defaultIfNull: defaultIfNull);
}
