import 'dart:async';

import 'package:flutter/services.dart';

import '../../../shared/security/safe_json.dart';
import '../models/market_price_models.dart';

class MarketPriceService {
  const MarketPriceService();

  Future<MarketSnapshot> fetchSnapshot({
    required String locationLabel,
    double? latitude,
    double? longitude,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final markets = await _loadMarketCenters();
    final userLatitude = latitude ?? 20.9674;
    final userLongitude = longitude ?? -89.5926;
    final nearbyMarkets = [...markets]
      ..sort((a, b) {
        final distanceA = a.distanceKmFrom(userLatitude, userLongitude);
        final distanceB = b.distanceKmFrom(userLatitude, userLongitude);
        return distanceA.compareTo(distanceB);
      });
    final nearestMarket = nearbyMarkets.first;
    final prices = _buildReferencePrices(markets)
      ..sort((a, b) {
        final distanceA = a.market.distanceKmFrom(userLatitude, userLongitude);
        final distanceB = b.market.distanceKmFrom(userLatitude, userLongitude);
        return distanceA.compareTo(distanceB);
      });

    return MarketSnapshot(
      prices: prices,
      nearbyMarkets: nearbyMarkets.take(8).toList(),
      nearestMarket: nearestMarket,
      locationLabel: locationLabel,
      isLiveSource: false,
    );
  }

  static List<MarketCenter>? _cachedMarkets;

  static Future<List<MarketCenter>> _loadMarketCenters() async {
    final cached = _cachedMarkets;
    if (cached != null) {
      return cached;
    }
    final rawJson = await rootBundle.loadString(
      'assets/data/market_centers.json',
    );
    final decoded = SafeJson.list(rawJson, maxBytes: 1024000);
    final markets = decoded
        .whereType<Map>()
        .map((item) => _tryReadMarket(item.cast<String, dynamic>()))
        .nonNulls
        .toList(growable: false);
    if (markets.isEmpty) {
      throw const FormatException('No hay centrales disponibles.');
    }
    _cachedMarkets = markets;
    return markets;
  }

  static MarketCenter? _tryReadMarket(Map<String, dynamic> item) {
    try {
      return MarketCenter.fromJson(item);
    } catch (_) {
      return null;
    }
  }

  static List<CropMarketPrice> _buildReferencePrices(
    List<MarketCenter> markets,
  ) {
    final now = DateTime.now();
    return <CropMarketPrice>[
      _price(
        cropId: 'limon',
        cropName: 'Limón',
        variety: 'sin semilla',
        market: _market(markets, 'merida'),
        price: 25.8,
        day: 3.4,
        week: 8.1,
        presentation: 'Caja 18 kg',
        color: const Color(0xFF7CB342),
        updatedAt: now,
        history: const <double>[22.2, 22.8, 23.1, 24.4, 24.9, 25.0, 25.8],
      ),
      _price(
        cropId: 'limon',
        cropName: 'Limón',
        variety: 'con semilla',
        market: _market(markets, 'casa_pueblo'),
        price: 24.1,
        day: 1.1,
        week: 4.9,
        presentation: 'Caja 18 kg',
        color: const Color(0xFF7CB342),
        updatedAt: now,
        history: const <double>[22.0, 22.2, 22.6, 23.0, 23.4, 23.9, 24.1],
      ),
      _price(
        cropId: 'limon',
        cropName: 'Limón',
        variety: 'sin semilla',
        market: _market(markets, 'oxkutzcab'),
        price: 24.6,
        day: 1.7,
        week: 5.6,
        presentation: 'Caja 18 kg',
        color: const Color(0xFF7CB342),
        updatedAt: now,
        history: const <double>[21.9, 22.4, 22.8, 23.2, 23.8, 24.2, 24.6],
      ),
      _price(
        cropId: 'papaya',
        cropName: 'Papaya',
        variety: 'Maradol',
        market: _market(markets, 'oxkutzcab'),
        price: 17.9,
        day: -0.6,
        week: 3.2,
        presentation: 'Kilogramo',
        color: const Color(0xFFF97316),
        updatedAt: now,
        history: const <double>[17.0, 17.1, 17.3, 17.5, 17.8, 18.0, 17.9],
      ),
      _price(
        cropId: 'papaya',
        cropName: 'Papaya',
        variety: 'Maradol',
        market: _market(markets, 'casa_pueblo'),
        price: 18.0,
        day: 0.4,
        week: 3.8,
        presentation: 'Kilogramo',
        color: const Color(0xFFF97316),
        updatedAt: now,
        history: const <double>[17.2, 17.3, 17.4, 17.6, 17.7, 17.9, 18.0],
      ),
      _price(
        cropId: 'papaya',
        cropName: 'Papaya',
        variety: 'Maradol',
        market: _market(markets, 'merida'),
        price: 18.4,
        day: -1.2,
        week: 4.8,
        presentation: 'Kilogramo',
        color: const Color(0xFFF97316),
        updatedAt: now,
        history: const <double>[17.1, 17.5, 17.9, 18.8, 18.7, 18.6, 18.4],
      ),
      _price(
        cropId: 'tomate',
        cropName: 'Tomate',
        variety: 'saladette',
        market: _market(markets, 'oxkutzcab'),
        price: 18.7,
        day: -0.4,
        week: -2.2,
        presentation: 'Caja 13 kg',
        color: const Color(0xFFE53935),
        updatedAt: now,
        history: const <double>[19.2, 19.1, 19.0, 18.9, 18.8, 18.8, 18.7],
      ),
      _price(
        cropId: 'tomate',
        cropName: 'Tomate',
        variety: 'bola',
        market: _market(markets, 'casa_pueblo'),
        price: 20.1,
        day: 1.0,
        week: -0.8,
        presentation: 'Caja 13 kg',
        color: const Color(0xFFE53935),
        updatedAt: now,
        history: const <double>[20.3, 20.2, 20.3, 20.0, 19.9, 19.9, 20.1],
      ),
      _price(
        cropId: 'papaya',
        cropName: 'Papaya',
        variety: 'Maradol',
        market: _market(markets, 'cancun'),
        price: 21.2,
        day: 2.9,
        week: 7.4,
        presentation: 'Kilogramo',
        color: const Color(0xFFF97316),
        updatedAt: now,
        history: const <double>[19.0, 19.2, 19.8, 20.1, 20.5, 20.6, 21.2],
      ),
      _price(
        cropId: 'maiz',
        cropName: 'Maíz',
        variety: 'blanco',
        market: _market(markets, 'casa_pueblo'),
        price: 8.7,
        day: 0.2,
        week: 1.9,
        presentation: 'Bulto 50 kg',
        color: const Color(0xFFEAB308),
        updatedAt: now,
        history: const <double>[8.5, 8.5, 8.6, 8.6, 8.7, 8.7, 8.7],
      ),
      _price(
        cropId: 'maiz',
        cropName: 'Maíz',
        variety: 'amarillo',
        market: _market(markets, 'ticul'),
        price: 8.4,
        day: 0.0,
        week: 1.1,
        presentation: 'Bulto 50 kg',
        color: const Color(0xFFEAB308),
        updatedAt: now,
        history: const <double>[8.3, 8.3, 8.3, 8.4, 8.4, 8.4, 8.4],
      ),
      _price(
        cropId: 'tomate',
        cropName: 'Tomate',
        variety: 'saladette',
        market: _market(markets, 'merida'),
        price: 19.6,
        day: 0.8,
        week: -3.1,
        presentation: 'Caja 13 kg',
        color: const Color(0xFFE53935),
        updatedAt: now,
        history: const <double>[20.2, 20.4, 20.1, 19.9, 19.5, 19.4, 19.6],
      ),
      _price(
        cropId: 'chile',
        cropName: 'Chile',
        variety: 'habanero primera',
        market: _market(markets, 'merida'),
        price: 74.2,
        day: 3.1,
        week: 10.4,
        presentation: 'Caja 10 kg',
        color: const Color(0xFFFF9800),
        updatedAt: now,
        history: const <double>[66.4, 67.8, 68.9, 70.2, 72.1, 72.8, 74.2],
      ),
      _price(
        cropId: 'chile',
        cropName: 'Chile',
        variety: 'habanero primera',
        market: _market(markets, 'ticul'),
        price: 71.3,
        day: 1.8,
        week: 8.9,
        presentation: 'Caja 10 kg',
        color: const Color(0xFFFF9800),
        updatedAt: now,
        history: const <double>[65.5, 66.0, 66.8, 68.1, 69.2, 70.0, 71.3],
      ),
      _price(
        cropId: 'tomate',
        cropName: 'Tomate',
        variety: 'saladette',
        market: _market(markets, 'iztapalapa'),
        price: 22.8,
        day: 2.2,
        week: 1.5,
        presentation: 'Caja 13 kg',
        color: const Color(0xFFE53935),
        updatedAt: now,
        history: const <double>[21.6, 21.8, 21.9, 22.1, 22.0, 22.3, 22.8],
      ),
      _price(
        cropId: 'sandia',
        cropName: 'Sandía',
        variety: 'rayada',
        market: _market(markets, 'valladolid'),
        price: 9.4,
        day: -1.4,
        week: -3.8,
        presentation: 'Kilogramo',
        color: const Color(0xFF43A047),
        updatedAt: now,
        history: const <double>[9.8, 9.8, 9.7, 9.6, 9.5, 9.5, 9.4],
      ),
      _price(
        cropId: 'maiz',
        cropName: 'Maíz',
        variety: 'blanco',
        market: _market(markets, 'merida'),
        price: 8.9,
        day: 0.0,
        week: 2.4,
        presentation: 'Bulto 50 kg',
        color: const Color(0xFFEAB308),
        updatedAt: now,
        history: const <double>[8.6, 8.6, 8.7, 8.7, 8.8, 8.9, 8.9],
      ),
      _price(
        cropId: 'maiz',
        cropName: 'Maíz',
        variety: 'blanco',
        market: _market(markets, 'guadalajara'),
        price: 9.4,
        day: 1.1,
        week: 3.3,
        presentation: 'Bulto 50 kg',
        color: const Color(0xFFEAB308),
        updatedAt: now,
        history: const <double>[9.0, 9.0, 9.1, 9.2, 9.2, 9.3, 9.4],
      ),
      _price(
        cropId: 'chile',
        cropName: 'Chile',
        variety: 'habanero primera',
        market: _market(markets, 'oxkutzcab'),
        price: 72.5,
        day: 4.2,
        week: 11.6,
        presentation: 'Caja 10 kg',
        color: const Color(0xFFFF9800),
        updatedAt: now,
        history: const <double>[62.8, 64.2, 65.1, 67.6, 69.8, 70.2, 72.5],
      ),
      _price(
        cropId: 'chile',
        cropName: 'Chile',
        variety: 'habanero primera',
        market: _market(markets, 'cancun'),
        price: 76.9,
        day: 2.6,
        week: 9.8,
        presentation: 'Caja 10 kg',
        color: const Color(0xFFFF9800),
        updatedAt: now,
        history: const <double>[69.0, 69.5, 70.8, 72.1, 73.5, 75.0, 76.9],
      ),
      _price(
        cropId: 'sandia',
        cropName: 'Sandía',
        variety: 'rayada',
        market: _market(markets, 'merida'),
        price: 9.8,
        day: -2.0,
        week: -5.2,
        presentation: 'Kilogramo',
        color: const Color(0xFF43A047),
        updatedAt: now,
        history: const <double>[10.4, 10.3, 10.2, 10.0, 9.9, 10.0, 9.8],
      ),
      _price(
        cropId: 'aguacate',
        cropName: 'Aguacate',
        variety: 'Hass',
        market: _market(markets, 'iztapalapa'),
        price: 68.3,
        day: 1.4,
        week: 6.2,
        presentation: 'Caja 10 kg',
        color: const Color(0xFF558B2F),
        updatedAt: now,
        history: const <double>[63.4, 64.0, 64.8, 66.2, 66.7, 67.4, 68.3],
      ),
      _price(
        cropId: 'mango',
        cropName: 'Mango',
        variety: 'Ataulfo',
        market: _market(markets, 'campeche'),
        price: 31.7,
        day: 3.1,
        week: 9.2,
        presentation: 'Caja 25 kg',
        color: const Color(0xFFFFB300),
        updatedAt: now,
        history: const <double>[28.2, 28.8, 29.1, 29.9, 30.4, 30.8, 31.7],
      ),
    ];
  }

  static MarketCenter _market(List<MarketCenter> markets, String id) {
    return markets.firstWhere((market) => market.id == id);
  }

  static CropMarketPrice _price({
    required String cropId,
    required String cropName,
    required String variety,
    required MarketCenter market,
    required double price,
    required double day,
    required double week,
    required String presentation,
    required Color color,
    required DateTime updatedAt,
    required List<double> history,
  }) {
    return CropMarketPrice(
      cropId: cropId,
      cropName: cropName,
      variety: variety,
      market: market,
      pricePerKg: price,
      dailyChangePercent: day,
      weeklyChangePercent: week,
      presentation: presentation,
      quality: 'Primera',
      updatedAt: updatedAt,
      source: 'Referencia local SNIIM/SIAP',
      color: color,
      history: List<MarketPricePoint>.generate(history.length, (index) {
        return MarketPricePoint(
          date: updatedAt.subtract(Duration(days: history.length - index - 1)),
          pricePerKg: history[index],
        );
      }),
    );
  }
}
