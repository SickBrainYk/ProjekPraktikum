class CurrencyConversionModel {
  final Map<String, double> rates;

  CurrencyConversionModel({required this.rates});

  factory CurrencyConversionModel.fromJson(Map<String, dynamic> jsonResponse) {
    final Map<String, double> parsedRates = {};

    final dynamic rawRates = jsonResponse['rates'];

    if (rawRates is Map) {
      rawRates.forEach((key, value) {
        if (value is num) {
          parsedRates[key.toString()] = value.toDouble();
        }
      });
    }

    return CurrencyConversionModel(rates: parsedRates);
  }
}
