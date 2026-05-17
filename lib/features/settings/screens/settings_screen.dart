import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/app_location.dart';
import '../../../shared/services/location/location_service.dart';
import '../../../shared/services/location/location_options_service.dart';
import '../../../shared/state/app_scope.dart';
import '../../../shared/widgets/cultiva_snackbar.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_switch_tile.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  late final TextEditingController _locationController;
  AppLocation? _selectedLocation;
  String? _selectedState;
  String? _loadedLocationName;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locationName = AppScope.of(context).settings.locationName;
    if (_loadedLocationName == locationName) {
      return;
    }
    _loadedLocationName = locationName;
    _locationController.text = locationName;
    _selectedLocation = LocationOptionsService.byLabel(locationName);
    _selectedState = _selectedLocation == null
        ? null
        : LocationOptionsService.stateOf(_selectedLocation!);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _toggleSetting(
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      if (!mounted) {
        return;
      }
      showCultivaSnackBar(
        context,
        message: successMessage,
        color: const Color(0xFF00C853),
      );
    } on LocationException catch (error) {
      if (!mounted) {
        return;
      }
      showCultivaSnackBar(
        context,
        message: error.message,
        color: Colors.redAccent,
        icon: Icons.location_off_outlined,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showCultivaSnackBar(
        context,
        message: 'No se pudo guardar el cambio.',
        color: Colors.redAccent,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _savePresetLocation(AppLocation location) {
    _loadedLocationName = location.label;
    _locationController.text = location.label;
    return _toggleSetting(
      () => AppScope.of(context).savePresetLocation(location),
      'Ubicación guardada correctamente.',
    );
  }

  Future<void> _saveTypedLocation() {
    final query = _locationController.text.trim();
    if (query.isEmpty) {
      showCultivaSnackBar(
        context,
        message: 'Escribe una ciudad o municipio válido.',
        color: Colors.redAccent,
        icon: Icons.warning_amber_rounded,
      );
      return Future<void>.value();
    }
    _loadedLocationName = query;
    return _toggleSetting(
      () => AppScope.of(context).saveManualLocation(query),
      'Ubicación guardada correctamente.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final settings = store.settings;
    final states = LocationOptionsService.states;
    final locationsForState = _selectedState == null
        ? const <AppLocation>[]
        : LocationOptionsService.optionsForState(_selectedState!);

    return Scaffold(
      backgroundColor: AppColors.screenBackground(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SettingsSectionCard(
                    icon: settings.darkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    title: 'Apariencia',
                    subtitle: 'Tema visual de la app',
                    child: SettingsSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Modo oscuro',
                      subtitle: 'Usar colores oscuros en toda la app',
                      value: settings.darkMode,
                      onChanged: (value) => _toggleSetting(
                        () => store.updateSettings(
                          settings.copyWith(darkMode: value),
                        ),
                        value
                            ? 'Modo oscuro activado.'
                            : 'Modo claro activado.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SettingsSectionCard(
                    icon: Icons.notifications_none,
                    title: 'Notificaciones',
                    subtitle: 'Gestiona tus alertas',
                    child: Column(
                      children: [
                        SettingsSwitchTile(
                          icon: Icons.cloud_outlined,
                          title: 'Alertas meteorológicas',
                          subtitle: 'Clima y condiciones',
                          value: settings.weatherAlerts,
                          onChanged: (value) => _toggleSetting(
                            () => store.updateSettings(
                              settings.copyWith(weatherAlerts: value),
                            ),
                            value
                                ? 'Alertas meteorológicas activadas.'
                                : 'Alertas meteorológicas desactivadas.',
                          ),
                        ),
                        SettingsSwitchTile(
                          icon: Icons.agriculture_outlined,
                          title: 'Alertas de cultivo',
                          subtitle: 'Eventos importantes',
                          value: settings.cropAlerts,
                          onChanged: (value) => _toggleSetting(
                            () => store.updateSettings(
                              settings.copyWith(cropAlerts: value),
                            ),
                            value
                                ? 'Alertas de cultivo activadas.'
                                : 'Alertas de cultivo desactivadas.',
                          ),
                        ),
                        SettingsSwitchTile(
                          icon: Icons.notifications_off_outlined,
                          title: 'Modo silencioso',
                          subtitle: 'Pausar temporalmente',
                          value: settings.silentMode,
                          onChanged: (value) => _toggleSetting(
                            () => store.updateSettings(
                              settings.copyWith(silentMode: value),
                            ),
                            value
                                ? 'Modo silencioso activado.'
                                : 'Modo silencioso desactivado.',
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tipos de alertas climáticas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _alertChip(
                              icon: Icons.cloud,
                              label: 'Lluvias',
                              active: settings.rainAlerts,
                              color: Colors.blue,
                              onTap: () => _toggleSetting(
                                () => store.updateSettings(
                                  settings.copyWith(
                                    rainAlerts: !settings.rainAlerts,
                                  ),
                                ),
                                settings.rainAlerts
                                    ? 'Alerta de lluvias desactivada.'
                                    : 'Alerta de lluvias activada.',
                              ),
                            ),
                            _alertChip(
                              icon: Icons.air,
                              label: 'Ciclones',
                              active: settings.cycloneAlerts,
                              color: Colors.red,
                              onTap: () => _toggleSetting(
                                () => store.updateSettings(
                                  settings.copyWith(
                                    cycloneAlerts: !settings.cycloneAlerts,
                                  ),
                                ),
                                settings.cycloneAlerts
                                    ? 'Alerta de ciclones desactivada.'
                                    : 'Alerta de ciclones activada.',
                              ),
                            ),
                            _alertChip(
                              icon: Icons.warning_amber_rounded,
                              label: 'Sequías',
                              active: settings.droughtAlerts,
                              color: Colors.amber,
                              onTap: () => _toggleSetting(
                                () => store.updateSettings(
                                  settings.copyWith(
                                    droughtAlerts: !settings.droughtAlerts,
                                  ),
                                ),
                                settings.droughtAlerts
                                    ? 'Alerta de sequía desactivada.'
                                    : 'Alerta de sequía activada.',
                              ),
                            ),
                            _alertChip(
                              icon: Icons.wb_sunny_outlined,
                              label: 'Calor extremo',
                              active: settings.heatAlerts,
                              color: Colors.orange,
                              onTap: () => _toggleSetting(
                                () => store.updateSettings(
                                  settings.copyWith(
                                    heatAlerts: !settings.heatAlerts,
                                  ),
                                ),
                                settings.heatAlerts
                                    ? 'Alerta de calor extremo desactivada.'
                                    : 'Alerta de calor extremo activada.',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SettingsSectionCard(
                    icon: Icons.map_outlined,
                    title: 'Ubicación',
                    subtitle: 'Clima por GPS, estado o municipio',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsSwitchTile(
                          icon: Icons.near_me_outlined,
                          title: 'Geolocalización automática',
                          subtitle: 'Usar ubicación actual del dispositivo',
                          value: settings.autoLocation,
                          onChanged: (value) => _toggleSetting(
                            () async {
                              if (value) {
                                await store.refreshCurrentLocation();
                                _locationController.text =
                                    store.settings.locationName;
                                return;
                              }
                              await store.updateSettings(
                                settings.copyWith(autoLocation: false),
                              );
                            },
                            value
                                ? 'Ubicación actual detectada correctamente.'
                                : 'Geolocalización automática desactivada.',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.subtleBackground(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border(context),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubicación activa',
                                style: TextStyle(
                                  color: AppColors.mutedText(context),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF0D5D33),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      settings.locationName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              DropdownButtonFormField<String>(
                                key: ValueKey<String>(
                                  'state-${settings.autoLocation}-${_selectedState ?? 'none'}',
                                ),
                                initialValue: settings.autoLocation
                                    ? null
                                    : _selectedState,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: 'Selecciona estado',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: states
                                    .map(
                                      (state) => DropdownMenuItem<String>(
                                        value: state,
                                        child: Text(state),
                                      ),
                                    )
                                    .toList(),
                                onChanged: settings.autoLocation
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedState = value;
                                          _selectedLocation = null;
                                        });
                                      },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<AppLocation>(
                                key: ValueKey<String>(
                                  'municipality-${settings.autoLocation}-${_selectedState ?? 'none'}-${_selectedLocation?.label ?? 'none'}',
                                ),
                                initialValue: settings.autoLocation
                                    ? null
                                    : _selectedLocation,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: _selectedState == null
                                      ? 'Elige un estado primero'
                                      : 'Selecciona ciudad o municipio',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: locationsForState
                                    .map(
                                      (option) => DropdownMenuItem<AppLocation>(
                                        value: option,
                                        child: Text(option.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged:
                                    settings.autoLocation ||
                                        locationsForState.isEmpty
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedLocation = value;
                                          _locationController.text =
                                              value?.label ?? '';
                                        });
                                      },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _locationController,
                                enabled: !settings.autoLocation,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText:
                                      'O escribe ciudad, municipio, estado',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: store.isBusy
                                          ? null
                                          : () => _toggleSetting(() async {
                                              await store
                                                  .refreshCurrentLocation();
                                              _locationController.text =
                                                  store.settings.locationName;
                                              final selected =
                                                  LocationOptionsService.byLabel(
                                                    store.settings.locationName,
                                                  );
                                              _selectedLocation = selected;
                                              _selectedState = selected == null
                                                  ? null
                                                  : LocationOptionsService.stateOf(
                                                      selected,
                                                    );
                                            }, 'Ubicación actual actualizada.'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0D5D33,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.my_location,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Detectar ubicación actual',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed:
                                    settings.autoLocation ||
                                        store.isBusy ||
                                        _selectedLocation == null
                                    ? null
                                    : () => _savePresetLocation(
                                        _selectedLocation!,
                                      ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0D5D33),
                                  side: const BorderSide(
                                    color: Color(0xFF0D5D33),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                icon: const Icon(Icons.place_outlined),
                                label: const Text(
                                  'Guardar estado y municipio',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: settings.autoLocation || store.isBusy
                                    ? null
                                    : _saveTypedLocation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                icon: const Icon(
                                  Icons.travel_explore,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Buscar y guardar ubicación escrita',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SettingsSectionCard(
                    icon: Icons.cloud_sync_outlined,
                    title: 'Datos y sincronización',
                    subtitle: 'Controla cómo se actualiza el clima',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsSwitchTile(
                          icon: Icons.signal_cellular_alt,
                          title: 'Usar datos móviles',
                          subtitle: 'Permite actualizar clima sin Wi-Fi',
                          value: settings.allowMobileData,
                          onChanged: (value) => _toggleSetting(
                            () async {
                              await store.updateSettings(
                                settings.copyWith(allowMobileData: value),
                              );
                              if (value) {
                                await store.refreshWeather();
                              }
                            },
                            value
                                ? 'Datos móviles activados.'
                                : 'Datos móviles desactivados.',
                          ),
                        ),
                        const SizedBox(height: 4),
                        _infoRow(
                          icon: store.hasNetworkConnection
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                          label: 'Estado de conexión',
                          value: store.hasNetworkConnection
                              ? 'Internet disponible'
                              : 'Sin internet disponible',
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.schedule,
                          label: 'Clima guardado',
                          value: store.lastWifiSyncAt == null
                              ? 'Aún sin sincronización'
                              : 'Última sincronización disponible',
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: store.isBusy ? null : store.refreshWeather,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0D5D33),
                            side: const BorderSide(color: Color(0xFF0D5D33)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualizar clima ahora'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SettingsSectionCard(
                    icon: Icons.info_outline,
                    title: 'Información de la app',
                    subtitle: 'Estado general',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Versión: 1.0.0',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cultivos registrados: ${store.activeCropsCount}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ubicación activa: ${settings.locationName}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + 40;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D5D33), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 32,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Personaliza tu experiencia',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alertChip({
    required IconData icon,
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.1)
              : AppColors.subtleBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? color : Colors.grey),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: active ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF0D5D33), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.mutedText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}
