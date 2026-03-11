import 'package:flutter/material.dart';

import '../../../shared/models/app_location.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/location_options_service.dart';
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

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locationName = AppScope.of(context).settings.locationName;
    _locationController.text = locationName;
    _selectedLocation = LocationOptionsService.byLabel(locationName);
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
      debugPrint('[ConfiguracionScreen] Ejecutando cambio: $successMessage');
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
      debugPrint('[ConfiguracionScreen] Error de ubicación: ${error.message}');
    } catch (error) {
      debugPrint('[ConfiguracionScreen] Error al guardar ajuste: $error');
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

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final settings = store.settings;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
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
                    subtitle: 'Configura tu zona',
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
                                debugPrint(
                                  '[ConfiguracionScreen] Activando geolocalización automática',
                                );
                                await store.refreshCurrentLocation();
                                _locationController.text =
                                    store.settings.locationName;
                                return;
                              }
                              debugPrint(
                                '[ConfiguracionScreen] Desactivando geolocalización automática',
                              );
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
                            color: const Color(
                              0xFF0D5D33,
                            ).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(
                                0xFF0D5D33,
                              ).withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ubicación activa',
                                style: TextStyle(
                                  color: Colors.grey,
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
                              DropdownButtonFormField<AppLocation>(
                                key: ValueKey<String>(
                                  '${settings.autoLocation}-${_selectedLocation?.label ?? 'none'}',
                                ),
                                initialValue: settings.autoLocation
                                    ? null
                                    : _selectedLocation,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Selecciona una ubicación',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: LocationOptionsService.options
                                    .map(
                                      (option) => DropdownMenuItem<AppLocation>(
                                        value: option,
                                        child: Text(option.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: settings.autoLocation
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
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: store.isBusy
                                          ? null
                                          : () => _toggleSetting(() async {
                                              debugPrint(
                                                '[ConfiguracionScreen] Tap en detectar ubicación actual',
                                              );
                                              await store
                                                  .refreshCurrentLocation();
                                              _locationController.text =
                                                  store.settings.locationName;
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
                              ElevatedButton(
                                onPressed: settings.autoLocation || store.isBusy
                                    ? null
                                    : () {
                                        final value = _selectedLocation;
                                        debugPrint(
                                          '[ConfiguracionScreen] Guardando ubicación manual: ${value?.label}',
                                        );
                                        if (value == null) {
                                          showCultivaSnackBar(
                                            context,
                                            message:
                                                'Selecciona una ubicación válida.',
                                            color: Colors.redAccent,
                                            icon: Icons.warning_amber_rounded,
                                          );
                                          return;
                                        }
                                        _toggleSetting(
                                          () => store.savePresetLocation(value),
                                          'Ubicación guardada correctamente.',
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Guardar ubicación manual',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
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
          color: active ? color.withValues(alpha: 0.1) : Colors.grey[100],
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
}
