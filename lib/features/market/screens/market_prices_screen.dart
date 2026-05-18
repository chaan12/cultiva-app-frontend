import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../crops_catalog/models/crop_catalog_item.dart';
import '../../crops_catalog/services/crop_catalog_service.dart';
import '../../../shared/state/app_scope.dart';
import '../models/market_price_models.dart';
import '../services/market_price_service.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final MarketPriceService _service = const MarketPriceService();
  final TextEditingController _cropSearchController = TextEditingController();
  Future<MarketSnapshot>? _snapshotFuture;
  String? _snapshotLocationKey;
  String? _selectedCrop;
  String _cropQuery = '';
  bool _showTon = false;
  bool _showAllCrops = false;

  @override
  void dispose() {
    _cropSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = AppScope.of(context).settings;
    final locationKey = _locationKey(
      settings.locationName,
      settings.latitude,
      settings.longitude,
    );
    if (_snapshotFuture == null || _snapshotLocationKey != locationKey) {
      _snapshotLocationKey = locationKey;
      _snapshotFuture = _loadSnapshot();
    }
  }

  String _locationKey(String name, double? latitude, double? longitude) {
    return '$name|${latitude?.toStringAsFixed(5)}|${longitude?.toStringAsFixed(5)}';
  }

  Future<MarketSnapshot> _loadSnapshot() {
    final settings = AppScope.of(context).settings;
    return _service.fetchSnapshot(
      locationLabel: settings.locationName,
      latitude: settings.latitude,
      longitude: settings.longitude,
    );
  }

  Future<void> _refresh() async {
    final future = _loadSnapshot();
    final settings = AppScope.of(context).settings;
    setState(() {
      _snapshotLocationKey = _locationKey(
        settings.locationName,
        settings.latitude,
        settings.longitude,
      );
      _snapshotFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground(context),
      body: FutureBuilder<MarketSnapshot>(
        key: ValueKey(_snapshotLocationKey),
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(onRetry: _refresh);
          }
          final data = snapshot.requireData;
          final hasNetworkConnection = AppScope.of(
            context,
          ).hasNetworkConnection;
          final allCrops = [...CropCatalogService.items]
            ..sort((a, b) => a.name.compareTo(b.name));
          final filteredCrops = allCrops.where((crop) {
            return _normalizeSearch(
              crop.name,
            ).contains(_normalizeSearch(_cropQuery));
          }).toList();
          final selectedExists = allCrops.any(
            (crop) => crop.name == _selectedCrop,
          );
          final defaultCrop = allCrops.firstWhere(
            (crop) => crop.id == 'maiz',
            orElse: () => allCrops.first,
          );
          final cropName = selectedExists ? _selectedCrop! : defaultCrop.name;
          final selectedPrices = data.pricesForCrop(cropName);
          final primaryPrice = selectedPrices.isEmpty
              ? null
              : selectedPrices.first;
          final pricedCropNames = data.cropNames.toSet();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _MarketHeader(
                  snapshot: data,
                  showTon: _showTon,
                  hasNetworkConnection: hasNetworkConnection,
                  onUnitChanged: (value) {
                    setState(() => _showTon = value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasNetworkConnection) ...[
                        _CropSelector(
                          crops: filteredCrops,
                          selectedCrop: cropName,
                          pricedCropNames: pricedCropNames,
                          controller: _cropSearchController,
                          query: _cropQuery,
                          showAll: _showAllCrops,
                          onQueryChanged: (value) {
                            setState(() => _cropQuery = value);
                          },
                          onToggleShowAll: () {
                            setState(() => _showAllCrops = !_showAllCrops);
                          },
                          onSelected: (value) {
                            setState(() {
                              _selectedCrop = value;
                              _showAllCrops = false;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        if (primaryPrice == null)
                          _NoCropPriceCard(cropName: cropName)
                        else ...[
                          _FeaturedPrices(
                            prices: selectedPrices,
                            showTon: _showTon,
                          ),
                          const SizedBox(height: 18),
                          _OtherMarketPricesSection(
                            prices: selectedPrices,
                            showTon: _showTon,
                          ),
                          const SizedBox(height: 18),
                          _MarketSummaryCard(
                            prices: selectedPrices,
                            marketCount: data.nearbyMarkets.length,
                            stateName: data.nearestMarket.state,
                            showTon: _showTon,
                          ),
                          const SizedBox(height: 18),
                          _TrendCard(price: primaryPrice, showTon: _showTon),
                          const SizedBox(height: 18),
                          _ComparisonSection(
                            prices: selectedPrices,
                            showTon: _showTon,
                            stateName: data.nearestMarket.state,
                          ),
                          const SizedBox(height: 18),
                        ],
                        _SourceStatusCard(snapshot: data),
                        const SizedBox(height: 18),
                      ],
                      _NearbyMarketsSection(markets: data.nearbyMarkets),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MarketHeader extends StatelessWidget {
  const _MarketHeader({
    required this.snapshot,
    required this.showTon,
    required this.hasNetworkConnection,
    required this.onUnitChanged,
  });

  final MarketSnapshot snapshot;
  final bool showTon;
  final bool hasNetworkConnection;
  final ValueChanged<bool> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final userLatitude = settings.latitude ?? 20.9674;
    final userLongitude = settings.longitude ?? -89.5926;
    final distance = snapshot.nearestMarket.distanceKmFrom(
      userLatitude,
      userLongitude,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.isDark(context)
              ? const <Color>[Color(0xFF102519), Color(0xFF123D27)]
              : const <Color>[Color(0xFF00572E), Color(0xFF00A344)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mercado agrícola',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasNetworkConnection
                          ? 'Precios, tendencias y centrales cercanas'
                          : 'Centrales cercanas disponibles sin internet',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Central más cercana',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.nearestMarket.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${snapshot.nearestMarket.city}, ${snapshot.nearestMarket.state} · ${snapshot.nearestMarket.type}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${distance.toStringAsFixed(0)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: snapshot.nearestMarket.mainProducts.map((product) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        product,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                if (hasNetworkConnection)
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<bool>(
                          segments: const <ButtonSegment<bool>>[
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('kg'),
                            ),
                            ButtonSegment<bool>(value: true, label: Text('tn')),
                          ],
                          selected: <bool>{showTon},
                          onSelectionChanged: (values) {
                            onUnitChanged(values.first);
                          },
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.10,
                            ),
                            selectedBackgroundColor: Colors.white,
                            selectedForegroundColor: const Color(0xFF00572E),
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        onPressed: () =>
                            _openMarketInMaps(context, snapshot.nearestMarket),
                        icon: const Icon(Icons.map_outlined),
                        tooltip: 'Abrir en Google Maps',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00572E),
                        ),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton.filledTonal(
                      onPressed: () =>
                          _openMarketInMaps(context, snapshot.nearestMarket),
                      icon: const Icon(Icons.map_outlined),
                      tooltip: 'Abrir en Google Maps',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00572E),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketSummaryCard extends StatelessWidget {
  const _MarketSummaryCard({
    required this.prices,
    required this.marketCount,
    required this.stateName,
    required this.showTon,
  });

  final List<CropMarketPrice> prices;
  final int marketCount;
  final String stateName;
  final bool showTon;

  @override
  Widget build(BuildContext context) {
    final lastUpdate = prices
        .map((price) => price.updatedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final averagePricePerKg =
        prices.fold<double>(0, (total, price) => total + price.pricePerKg) /
        prices.length;
    final averageWeeklyChange =
        prices.fold<double>(
          0,
          (total, price) => total + price.weeklyChangePercent,
        ) /
        prices.length;
    final averagePrice = showTon ? averagePricePerKg * 1000 : averagePricePerKg;
    final cropName = prices.first.cropName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.insights_outlined,
            title: 'Resumen de mercado',
            subtitle: 'Indicadores del cultivo seleccionado',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.schedule_outlined,
                  label: 'Actualizado',
                  value: DateFormat('d MMM, HH:mm', 'es_MX').format(lastUpdate),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.payments_outlined,
                  label: showTon ? 'Promedio / tn' : 'Promedio / kg',
                  value: _formatMoney(averagePrice),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.location_city_outlined,
                  label: cropName,
                  value: '$marketCount en $stateName',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.trending_up,
                  label: 'Semana',
                  value: _formatChange(averageWeeklyChange),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.subtleBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.greenText(context), size: 19),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.mutedText(context), fontSize: 11),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceStatusCard extends StatelessWidget {
  const _SourceStatusCard({required this.snapshot});

  final MarketSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final color = snapshot.isLiveSource
        ? AppColors.greenText(context)
        : const Color(0xFFB36B00);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              snapshot.isLiveSource
                  ? Icons.wifi_tethering
                  : Icons.dataset_outlined,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              snapshot.isLiveSource
                  ? 'Fuente conectada: SNIIM/SIAP. Los precios se muestran como referencia de mercado mayorista.'
                  : 'Vista preparada para SNIIM/SIAP con datos locales de referencia. Lista para conectar el extractor oficial.',
              style: TextStyle(
                color: AppColors.primaryText(context),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropSelector extends StatelessWidget {
  const _CropSelector({
    required this.crops,
    required this.selectedCrop,
    required this.pricedCropNames,
    required this.controller,
    required this.query,
    required this.showAll,
    required this.onQueryChanged,
    required this.onToggleShowAll,
    required this.onSelected,
  });

  final List<CropCatalogItem> crops;
  final String selectedCrop;
  final Set<String> pricedCropNames;
  final TextEditingController controller;
  final String query;
  final bool showAll;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onToggleShowAll;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedCrops = crops.where((crop) => crop.name == selectedCrop);
    final selectedCropItems = selectedCrops.toList();
    final pricedCrops = crops
        .where(
          (crop) =>
              crop.name != selectedCrop && pricedCropNames.contains(crop.name),
        )
        .toList();
    final unpricedCrops = crops
        .where(
          (crop) =>
              crop.name != selectedCrop && !pricedCropNames.contains(crop.name),
        )
        .toList();
    final showFullList = showAll || query.trim().isNotEmpty;
    final primaryCrops = showFullList
        ? <CropCatalogItem>[...selectedCropItems, ...pricedCrops]
        : <CropCatalogItem>[
            ...selectedCropItems,
            ...pricedCrops.take(8 - selectedCropItems.length),
          ];
    final shouldShowUnpriced = showFullList && unpricedCrops.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.grass_outlined,
          title: 'Consultar cultivo',
          subtitle: 'Todos los cultivos del catálogo',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Buscar cultivo...',
            prefixIcon: Icon(Icons.search, color: AppColors.mutedText(context)),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onQueryChanged('');
                    },
                    icon: const Icon(Icons.close),
                    tooltip: 'Limpiar búsqueda',
                  ),
            filled: true,
            fillColor: AppColors.cardBackground(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (crops.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Text(
              'No hay cultivos con ese nombre.',
              style: TextStyle(
                color: AppColors.mutedText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth >= 520
                  ? (constraints.maxWidth - 20) / 3
                  : (constraints.maxWidth - 10) / 2;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CropGrid(
                    crops: primaryCrops,
                    selectedCrop: selectedCrop,
                    pricedCropNames: pricedCropNames,
                    itemWidth: itemWidth,
                    onSelected: onSelected,
                  ),
                  if (shouldShowUnpriced) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Sin precio',
                      style: TextStyle(
                        color: AppColors.mutedText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _CropGrid(
                      crops: unpricedCrops,
                      selectedCrop: selectedCrop,
                      pricedCropNames: pricedCropNames,
                      itemWidth: itemWidth,
                      onSelected: onSelected,
                    ),
                  ],
                ],
              );
            },
          ),
        if (crops.length > 8 && query.trim().isEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onToggleShowAll,
              icon: Icon(
                showAll ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              ),
              label: Text(showAll ? 'Ver menos' : 'Ver más cultivos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.greenText(context),
                side: BorderSide(color: AppColors.border(context)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CropGrid extends StatelessWidget {
  const _CropGrid({
    required this.crops,
    required this.selectedCrop,
    required this.pricedCropNames,
    required this.itemWidth,
    required this.onSelected,
  });

  final List<CropCatalogItem> crops;
  final String selectedCrop;
  final Set<String> pricedCropNames;
  final double itemWidth;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: crops.map((crop) {
        final selected = crop.name == selectedCrop;
        final hasPrice = pricedCropNames.contains(crop.name);
        return SizedBox(
          width: itemWidth,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(crop.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.greenIconBackground(context)
                    : AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? AppColors.greenPrimary
                      : AppColors.border(context),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: crop.badgeColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(crop.icon, color: crop.badgeColor, size: 19),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? AppColors.greenText(context)
                                : AppColors.primaryText(context),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasPrice ? 'con precio' : 'sin precio',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasPrice
                                ? AppColors.greenText(context)
                                : AppColors.mutedText(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeaturedPrices extends StatelessWidget {
  const _FeaturedPrices({required this.prices, required this.showTon});

  final List<CropMarketPrice> prices;
  final bool showTon;

  @override
  Widget build(BuildContext context) {
    final lead = prices.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.trending_up,
          title: 'Mejor precio del día',
          subtitle: 'Mejor mercado para ${lead.cropName}',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                lead.color.withValues(
                  alpha: AppColors.isDark(context) ? 0.35 : 0.18,
                ),
                AppColors.cardBackground(context),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: lead.color.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: lead.color.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: lead.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.eco_outlined, color: lead.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.cropName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lead.variety} · ${lead.market.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mutedText(context),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatMoney(
                              showTon ? lead.pricePerTon : lead.pricePerKg,
                            ),
                            style: TextStyle(
                              color: AppColors.greenText(context),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _ChangePill(value: lead.weeklyChangePercent),
                      ],
                    ),
                    Text(
                      showTon ? 'por tonelada' : 'por kilogramo',
                      style: TextStyle(
                        color: AppColors.mutedText(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoCropPriceCard extends StatelessWidget {
  const _NoCropPriceCard({required this.cropName});

  final String cropName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFB36B00).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.info_outline, color: Color(0xFFB36B00)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cropName aún no tiene precio',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'El cultivo está en el catálogo, pero todavía no hay datos de mercado cargados para esta vista.',
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.price, required this.showTon});

  final CropMarketPrice price;
  final bool showTon;

  @override
  Widget build(BuildContext context) {
    final values = price.history.map((point) => point.pricePerKg).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.96;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.04;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionTitle(
                  icon: Icons.show_chart,
                  title: 'Historial y tendencia',
                  subtitle: '${price.cropName} · ${price.market.city}',
                ),
              ),
              _ChangePill(value: price.dailyChangePercent, label: '24h'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.border(context), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, _) => Text(
                        NumberFormat.compactCurrency(
                          locale: 'es_MX',
                          symbol: r'$',
                          decimalDigits: 0,
                        ).format(showTon ? value * 1000 : value),
                        style: TextStyle(
                          color: AppColors.mutedText(context),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= price.history.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat(
                              'd MMM',
                              'es_MX',
                            ).format(price.history[index].date),
                            style: TextStyle(
                              color: AppColors.mutedText(context),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List<FlSpot>.generate(price.history.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        price.history[index].pricePerKg,
                      );
                    }),
                    isCurved: true,
                    color: price.color,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: price.color.withValues(alpha: 0.12),
                    ),
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: price.color,
                            strokeColor: AppColors.cardBackground(context),
                            strokeWidth: 2,
                          ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primaryText(context),
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final value = showTon ? spot.y * 1000 : spot.y;
                        return LineTooltipItem(
                          _formatMoney(value),
                          TextStyle(
                            color: AppColors.cardBackground(context),
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherMarketPricesSection extends StatelessWidget {
  const _OtherMarketPricesSection({
    required this.prices,
    required this.showTon,
  });

  final List<CropMarketPrice> prices;
  final bool showTon;

  @override
  Widget build(BuildContext context) {
    final bestPrice = prices.isEmpty ? null : prices.first;
    final otherPrices = prices.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.store_mall_directory_outlined,
          title: 'Precio en otros lugares',
          subtitle: 'Mismo cultivo: ${prices.first.cropName}',
        ),
        const SizedBox(height: 12),
        if (bestPrice == null || otherPrices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Text(
              'No hay otros mercados locales para comparar este cultivo.',
              style: TextStyle(
                color: AppColors.mutedText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: otherPrices.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final price = otherPrices[index];
                final difference = price.pricePerKg - bestPrice.pricePerKg;
                return Container(
                  width: 190,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.market.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price.market.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.mutedText(context),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatMoney(
                                showTon ? price.pricePerTon : price.pricePerKg,
                              ),
                              style: TextStyle(
                                color: AppColors.greenText(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _SmallDeltaPill(value: difference),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection({
    required this.prices,
    required this.showTon,
    required this.stateName,
  });

  final List<CropMarketPrice> prices;
  final bool showTon;
  final String stateName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.compare_arrows,
          title: 'Comparación local',
          subtitle: 'Solo centrales y mercados de $stateName',
        ),
        const SizedBox(height: 12),
        ...prices.map((price) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: price.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.store_outlined, color: price.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.market.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${price.variety} · ${price.presentation}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatMoney(
                          showTon ? price.pricePerTon : price.pricePerKg,
                        ),
                        style: TextStyle(
                          color: AppColors.greenText(context),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      _ChangePill(value: price.weeklyChangePercent),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _NearbyMarketsSection extends StatelessWidget {
  const _NearbyMarketsSection({required this.markets});

  final List<MarketCenter> markets;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final userLatitude = settings.latitude ?? 20.9674;
    final userLongitude = settings.longitude ?? -89.5926;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.map_outlined,
          title: 'Centrales cercanas',
          subtitle: 'Opciones dentro de ${markets.first.state}',
        ),
        const SizedBox(height: 12),
        ...markets.map((market) {
          final distance = market.distanceKmFrom(userLatitude, userLongitude);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _MarketCenterDetailScreen(market: market),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.greenIconBackground(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.location_city_outlined,
                          color: AppColors.greenText(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              market.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${market.city}, ${market.state} · ${market.type}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.mutedText(context),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 6,
                              runSpacing: 5,
                              children: market.mainProducts.take(4).map((
                                product,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.greenIconBackground(
                                      context,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    product,
                                    style: TextStyle(
                                      color: AppColors.greenText(context),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${distance.toStringAsFixed(0)} km',
                            style: TextStyle(
                              color: AppColors.greenText(context),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.mutedText(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MarketCenterDetailScreen extends StatelessWidget {
  const _MarketCenterDetailScreen({required this.market});

  final MarketCenter market;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final userLatitude = settings.latitude ?? 20.9674;
    final userLongitude = settings.longitude ?? -89.5926;
    final distance = market.distanceKmFrom(userLatitude, userLongitude);
    final phones = market.phoneNumbers.isEmpty
        ? const <String>['Por confirmar']
        : market.phoneNumbers;

    return Scaffold(
      backgroundColor: AppColors.screenBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground(context),
        foregroundColor: AppColors.primaryText(context),
        elevation: 0,
        title: const Text('Detalle de central'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.isDark(context)
                    ? const <Color>[Color(0xFF102519), Color(0xFF123D27)]
                    : const <Color>[Color(0xFF00572E), Color(0xFF00A344)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.location_city_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  market.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${market.city}, ${market.state} · ${market.type}',
                  style: const TextStyle(color: Colors.white70, height: 1.3),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetric(
                        icon: Icons.route_outlined,
                        label: 'Desde parcela',
                        value: '${distance.toStringAsFixed(1)} km',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroMetric(
                        icon: Icons.schedule_outlined,
                        label: 'Horario',
                        value: market.openingHours ?? 'Por confirmar',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openMarketDirections(context, market),
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('Ruta GPS'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openMarketInMaps(context, market),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver mapa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MarketDetailCard(
            title: 'Información operativa',
            children: [
              _MarketInfoTile(
                icon: Icons.schedule_outlined,
                label: 'Horarios',
                value: market.openingHours ?? 'Por confirmar con la central',
              ),
              _MarketInfoTile(
                icon: Icons.call_outlined,
                label: 'Teléfonos',
                value: phones.join('\n'),
                action: market.phoneNumbers.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Llamar',
                        onPressed: () => _openPhoneNumber(
                          context,
                          market.phoneNumbers.first,
                        ),
                        icon: const Icon(Icons.call_outlined),
                      ),
              ),
              _MarketInfoTile(
                icon: Icons.location_on_outlined,
                label: 'Ubicación',
                value:
                    market.address ??
                    '${market.city}, ${market.state}\n${market.latitude.toStringAsFixed(4)}, ${market.longitude.toStringAsFixed(4)}',
              ),
              if (market.accessNotes != null)
                _MarketInfoTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Acceso',
                  value: market.accessNotes!,
                ),
            ],
          ),
          const SizedBox(height: 18),
          _MapPreviewCard(market: market),
          const SizedBox(height: 18),
          _MarketDetailCard(
            title: 'Cultivos que normalmente compran',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: market.mainProducts.map((product) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenIconBackground(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      product,
                      style: TextStyle(
                        color: AppColors.greenText(context),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 19),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketDetailCard extends StatelessWidget {
  const _MarketDetailCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _MarketInfoTile extends StatelessWidget {
  const _MarketInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.action,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.greenIconBackground(context),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.greenText(context), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.market});

  final MarketCenter market;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground(context),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openMarketInMaps(context, market),
        child: Container(
          height: 154,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.greenIconBackground(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapGridPainter(
                    lineColor: AppColors.greenText(
                      context,
                    ).withValues(alpha: 0.16),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.greenText(context),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 31,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Text(
                  '${market.latitude.toStringAsFixed(4)}, ${market.longitude.toStringAsFixed(4)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2;
    for (var x = 18.0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x - 28, size.height), paint);
    }
    for (var y = 18.0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 22), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.greenText(context), size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.mutedText(context),
                  height: 1.25,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChangePill extends StatelessWidget {
  const _ChangePill({required this.value, this.label = '7d'});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final color = positive ? const Color(0xFF0F8B3D) : const Color(0xFFD23F31);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label ${positive ? '+' : ''}${value.toStringAsFixed(1)}%',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallDeltaPill extends StatelessWidget {
  const _SmallDeltaPill({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final positive = value > 0;
    final neutral = value.abs() < 0.01;
    final color = neutral
        ? AppColors.mutedText(context)
        : positive
        ? const Color(0xFF0F8B3D)
        : const Color(0xFFD23F31);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        neutral ? 'igual' : '${positive ? '+' : ''}${_formatMoney(value)}/kg',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: AppColors.greenText(context),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'No se pudieron cargar los precios.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(double value) {
  return NumberFormat.currency(
    locale: 'es_MX',
    symbol: r'$',
    decimalDigits: value >= 100 ? 0 : 2,
  ).format(value);
}

String _formatChange(double value) {
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}% semanal';
}

Future<void> _openMarketInMaps(
  BuildContext context,
  MarketCenter market,
) async {
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': '${market.latitude},${market.longitude}',
  });
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showMapError(context);
    }
  } on MissingPluginException {
    if (context.mounted) {
      _showMapError(context);
    }
  }
}

Future<void> _openMarketDirections(
  BuildContext context,
  MarketCenter market,
) async {
  final settings = AppScope.of(context).settings;
  final origin = settings.latitude == null || settings.longitude == null
      ? null
      : '${settings.latitude},${settings.longitude}';
  final queryParameters = <String, String>{
    'api': '1',
    'destination': '${market.latitude},${market.longitude}',
    'travelmode': 'driving',
  };
  if (origin != null) {
    queryParameters['origin'] = origin;
  }
  final uri = Uri.https('www.google.com', '/maps/dir/', queryParameters);
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showMapError(context);
    }
  } on MissingPluginException {
    if (context.mounted) {
      _showMapError(context);
    }
  }
}

Future<void> _openPhoneNumber(BuildContext context, String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la llamada.')),
      );
    }
  } on MissingPluginException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo iniciar la llamada. Reinicia la app después de instalar plugins.',
          ),
        ),
      );
    }
  }
}

void _showMapError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'No se pudo abrir Maps. Reinicia la app después de instalar plugins.',
      ),
    ),
  );
}

String _normalizeSearch(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');
}
