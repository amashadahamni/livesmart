class PropertyQueryResult {
  final String answer;
  final List<Map<String, String>> properties;
  final bool isPropertySearch;

  const PropertyQueryResult({
    required this.answer,
    required this.properties,
    required this.isPropertySearch,
  });
}

class PropertyNlp {
  static PropertyQueryResult answer(
    String input,
    List<Map<String, String>> properties, {
    DateTime? now,
  }) {
    final query = input.trim().toLowerCase();
    if (query.isEmpty) {
      return const PropertyQueryResult(
        answer: 'Tell me the property type, city, budget, bedrooms, or whether you want to buy or rent.',
        properties: [],
        isPropertySearch: false,
      );
    }

    if (_isGreeting(query)) {
      final hour = (now ?? DateTime.now()).hour;
      final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
      return PropertyQueryResult(
        answer: '$greeting! How can I help you find a property today?',
        properties: const [],
        isPropertySearch: false,
      );
    }

    if (_asksAboutApp(query)) {
      return const PropertyQueryResult(
        answer: 'LiveSmart can search verified property listings by city, type, budget, bedrooms, and sale or rent. You can also save favourites, contact sellers, and view properties on the map.',
        properties: [],
        isPropertySearch: false,
      );
    }

    final category = _categoryFor(query);
    final transaction = _transactionFor(query);
    final bedrooms = _bedroomsFor(query);
    final maxPrice = _maxPriceFor(query);
    final city = _cityFor(query, properties);
    final propertySearch = category != null || transaction != null || bedrooms != null || maxPrice != null || city != null || _hasPropertyWords(query);

    if (!propertySearch) {
      return const PropertyQueryResult(
        answer: 'I can help with property searches. Try: "house for sale in Colombo under 200 million" or "2-bedroom apartment in Kandy for rent".',
        properties: [],
        isPropertySearch: false,
      );
    }

    var matches = properties.where((property) {
      if (category != null && property['category'] != category) return false;
      if (transaction != null && property['transactionType']?.toLowerCase() != transaction) return false;
      if (bedrooms != null && int.tryParse(property['beds'] ?? '') != bedrooms) return false;
      if (city != null && !_normalize(property['city'] ?? '').contains(city)) return false;
      if (maxPrice != null) {
        final price = _listingPriceInMillions(property);
        if (price == null || price > maxPrice) return false;
      }
      return true;
    }).toList();

    matches.sort((left, right) {
      final leftPrice = _listingPriceInMillions(left) ?? double.infinity;
      final rightPrice = _listingPriceInMillions(right) ?? double.infinity;
      return leftPrice.compareTo(rightPrice);
    });

    final shown = matches.take(8).toList();
    if (shown.isEmpty) {
      return PropertyQueryResult(
        answer: 'I could not find a listing that matches ${_criteriaDescription(category, city, transaction, bedrooms, maxPrice)}. Try increasing the budget, changing the city, or removing one filter.',
        properties: const [],
        isPropertySearch: true,
      );
    }

    final shownText = matches.length > shown.length ? ' I am showing the best ${shown.length} matches.' : '';
    return PropertyQueryResult(
      answer: 'I found ${matches.length} ${_criteriaDescription(category, city, transaction, bedrooms, maxPrice)}.$shownText Tap a property to view its verified details.',
      properties: shown,
      isPropertySearch: true,
    );
  }

  static bool _isGreeting(String query) => RegExp(r'^(hi|hello|hey|good morning|good afternoon|good evening)\b').hasMatch(query);

  static bool _asksAboutApp(String query) => query.contains('livesmart app') || query.contains('what can you do') || query.contains('how does this app work');

  static bool _hasPropertyWords(String query) => RegExp(r'\b(property|properties|home|house|apartment|flat|land|plot|villa|commercial|office|rent|sale|buy)\b').hasMatch(query);

  static String? _categoryFor(String query) {
    if (RegExp(r'\b(apartments?|flats?|condos?)\b').hasMatch(query)) return 'Apartment';
    if (RegExp(r'\b(lands?|plots?)\b').hasMatch(query)) return 'Land';
    if (RegExp(r'\b(commercial|office|offices|shops?)\b').hasMatch(query)) return 'Commercial';
    if (RegExp(r'\b(houses?|homes?|villas?|bungalows?)\b').hasMatch(query)) return 'House';
    return null;
  }

  static String? _transactionFor(String query) {
    if (RegExp(r'\b(rent|rental|lease)\b').hasMatch(query)) return 'rent';
    if (RegExp(r'\b(sale|buy|purchase)\b').hasMatch(query)) return 'buy';
    return null;
  }

  static int? _bedroomsFor(String query) {
    final digits = RegExp(r'\b(\d+)\s*(?:-|\s)?(?:bed|bedroom|bedrooms|br)\b').firstMatch(query);
    if (digits != null) return int.tryParse(digits.group(1)!);
    const words = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6};
    for (final entry in words.entries) {
      if (RegExp('\\b${entry.key}\\s*(?:-|\\s)?(?:bed|bedroom|bedrooms)\\b').hasMatch(query)) return entry.value;
    }
    return null;
  }

  static double? _maxPriceFor(String query) {
    final match = RegExp(r'\b(?:under|below|less than|maximum|max|upto|up to)\s*(?:lkr|rs\.?|rupees?)?\s*([\d,.]+)\s*(million|mn|m|billion|bn|b)?').firstMatch(query);
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!.replaceAll(',', ''));
    if (value == null) return null;
    final unit = match.group(2);
    if (unit == 'billion' || unit == 'bn' || unit == 'b') return value * 1000;
    if (unit == 'million' || unit == 'mn' || unit == 'm') return value;
    return value >= 100000 ? value / 1000000 : value;
  }

  static String? _cityFor(String query, List<Map<String, String>> properties) {
    final cities = properties.map((property) => property['city'] ?? '').where((city) => city.isNotEmpty).toSet();
    final orderedCities = cities.toList()..sort((left, right) => right.length.compareTo(left.length));
    for (final city in orderedCities) {
      final normalized = _normalize(city);
      if (normalized.isNotEmpty && query.contains(normalized)) return normalized;
      final baseCity = normalized.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
      if (baseCity.length > 2 && query.contains(baseCity)) return baseCity;
    }
    final principalCities = <String>{
      for (final city in cities)
        _normalize(city).replaceAll(RegExp(r'\s+\d+.*$|\s*\([^)]*\)'), '').trim(),
    }.where((city) => city.length > 2).toList()..sort((left, right) => right.length.compareTo(left.length));
    for (final city in principalCities) {
      if (RegExp('\\b${RegExp.escape(city)}\\b').hasMatch(query)) return city;
    }
    return null;
  }

  static double? _priceInMillions(String price) {
    final normalized = price.toLowerCase().replaceAll(',', '');
    if (normalized.contains('price on request')) return null;
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*(million|mn|m|billion|bn|b)?').firstMatch(normalized);
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!);
    if (value == null) return null;
    final unit = match.group(2);
    if (unit == 'billion' || unit == 'bn' || unit == 'b') return value * 1000;
    if (unit == 'million' || unit == 'mn' || unit == 'm') return value;
    return value >= 100000 ? value / 1000000 : value;
  }

  static double? _listingPriceInMillions(Map<String, String> property) {
    final price = property['price'] ?? '';
    final perUnitPrice = _priceInMillions(price);
    if (perUnitPrice == null) return null;
    if (!price.toLowerCase().contains('per perch')) return perUnitPrice;

    final areaMatch = RegExp(r'(\d+(?:\.\d+)?)\s*perches?').firstMatch((property['area'] ?? '').toLowerCase());
    final perches = areaMatch == null ? null : double.tryParse(areaMatch.group(1)!);
    return perches == null ? null : perUnitPrice * perches;
  }

  static String _criteriaDescription(String? category, String? city, String? transaction, int? bedrooms, double? maxPrice) {
    final parts = <String>[];
    if (bedrooms != null) parts.add('$bedrooms-bedroom');
    if (category != null) parts.add(category.toLowerCase());
    if (transaction != null) parts.add('for $transaction');
    if (city != null) parts.add('in ${_displayCity(city)}');
    if (maxPrice != null) parts.add('under LKR ${maxPrice.toStringAsFixed(maxPrice.truncateToDouble() == maxPrice ? 0 : 1)} million');
    return parts.isEmpty ? 'properties' : parts.join(' ');
  }

  static String _displayCity(String city) => city.split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');

  static String _normalize(String value) => value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}
