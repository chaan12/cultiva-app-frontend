import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/crop_record.dart';
import '../../../shared/state/app_scope.dart';
import '../../../shared/widgets/cultiva_snackbar.dart';
import '../../crops_catalog/models/crop_catalog_item.dart';
import '../../crops_catalog/services/crop_catalog_service.dart';
import '../widgets/crop_option_card.dart';
import '../widgets/register_field_card.dart';

class CropRegisterScreen extends StatefulWidget {
  const CropRegisterScreen({super.key, this.initialCropId});

  final String? initialCropId;

  @override
  State<CropRegisterScreen> createState() => _CropRegisterScreenState();
}

class _CropRegisterScreenState extends State<CropRegisterScreen> {
  static final DateTime _minSowingDate = DateTime(2020);
  static final DateTime _maxSowingDate = DateTime(2100);
  static const double _maxAreaHa = 100000;

  int _step = 1;
  CropCatalogItem? _selectedCrop;
  bool _showSuccess = false;
  final _areaController = TextEditingController();
  final _cropSearchController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  Timer? _successTimer;
  Map<String, String> _errors = <String, String>{};
  String _cropQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = AppScope.of(context).settings.locationName;
    if (_locationController.text.isEmpty) {
      _locationController.text = location;
    }
    if (_selectedCrop == null && widget.initialCropId != null) {
      final preset = CropCatalogService.byId(widget.initialCropId!);
      _selectedCrop = preset;
      _step = 2;
    }
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    _areaController.dispose();
    _cropSearchController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _normalizeCropSearch(String value) {
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: _minSowingDate,
      lastDate: _maxSowingDate,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDate = picked;
      _dateController.text = DateFormat('dd / MM / yyyy').format(picked);
      _errors = Map<String, String>.from(_errors)..remove('fecha');
    });
  }

  bool _validateFields() {
    final errors = <String, String>{};
    final areaText = _areaController.text.trim().replaceAll(',', '.');
    final area = double.tryParse(areaText);

    if (_selectedCrop == null) {
      showCultivaSnackBar(
        context,
        message: 'Selecciona primero el cultivo que vas a registrar.',
        color: Colors.redAccent,
        icon: Icons.warning_amber_rounded,
      );
      return false;
    }
    if (areaText.isEmpty) {
      errors['area'] = 'El área es obligatoria.';
    } else if (area == null) {
      errors['area'] = 'Ingresa un número válido.';
    } else if (area <= 0) {
      errors['area'] = 'El área no puede ser cero ni negativa.';
    } else if (!area.isFinite || area > _maxAreaHa) {
      errors['area'] = 'Ingresa un área realista.';
    }
    if (_selectedDate == null) {
      errors['fecha'] = 'Selecciona una fecha de siembra.';
    } else if (_selectedDate!.isBefore(_minSowingDate) ||
        _selectedDate!.isAfter(_maxSowingDate)) {
      errors['fecha'] = 'La fecha de siembra está fuera del rango permitido.';
    }
    if (_locationController.text.trim().isEmpty) {
      errors['ubicacion'] = 'La ubicación es obligatoria.';
    }

    setState(() {
      _errors = errors;
    });

    if (errors.isNotEmpty) {
      showCultivaSnackBar(
        context,
        message: errors.values.first,
        color: Colors.redAccent,
        icon: Icons.error_outline,
      );
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validateFields() || _selectedCrop == null || _selectedDate == null) {
      return;
    }
    final area = double.parse(_areaController.text.trim().replaceAll(',', '.'));
    final record = CropRecord.fromCatalog(
      item: _selectedCrop!,
      areaHa: area,
      sowingDate: _selectedDate!,
      locationName: _locationController.text.trim(),
    );
    await AppScope.of(context).addCrop(record);
    if (!mounted) {
      return;
    }
    setState(() => _showSuccess = true);
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: isLandscape ? 40 : 24,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showSuccess
                      ? _buildSuccessView()
                      : switch (_step) {
                          1 => _buildSelectCrop(isLandscape),
                          2 => _buildCropDetails(),
                          _ => _buildConfirmStep(),
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D5D33),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                'Registrar cultivo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(3, (index) {
              final step = index + 1;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  decoration: BoxDecoration(
                    color: step <= _step
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectCrop(bool isLandscape) {
    final normalizedQuery = _normalizeCropSearch(_cropQuery);
    final cropOptions = CropCatalogService.items.where((item) {
      return _normalizeCropSearch(item.name).contains(normalizedQuery) ||
          _normalizeCropSearch(item.season).contains(normalizedQuery) ||
          _normalizeCropSearch(item.description).contains(normalizedQuery);
    }).toList();

    return Column(
      key: const ValueKey<int>(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          '¿Qué vas a sembrar?',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Selecciona el tipo de cultivo para tu nueva plantación',
          style: TextStyle(color: AppColors.mutedText(context)),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _cropSearchController,
          onChanged: (value) => setState(() => _cropQuery = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar cultivo...',
            prefixIcon: Icon(Icons.search, color: AppColors.mutedText(context)),
            suffixIcon: _cropQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar búsqueda',
                    onPressed: () {
                      setState(() {
                        _cropSearchController.clear();
                        _cropQuery = '';
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      color: AppColors.mutedText(context),
                    ),
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF0D5D33), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (cropOptions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_outlined,
                  color: AppColors.mutedText(context),
                  size: 36,
                ),
                const SizedBox(height: 10),
                Text(
                  'No encontramos cultivos con ese nombre.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cropOptions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isLandscape ? 0.85 : 0.7,
            ),
            itemBuilder: (_, index) {
              final item = cropOptions[index];
              return CropOptionCard(
                item: item,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _selectedCrop = item;
                    _step = 2;
                  });
                },
              );
            },
          ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCropDetails() {
    final crop = _selectedCrop!;

    return Column(
      key: const ValueKey<int>(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          'Detalles de la plantación',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Ingresa información de tu cultivo de ${crop.name}',
          style: TextStyle(color: AppColors.mutedText(context)),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: crop.badgeColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: crop.badgeColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(crop.icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.name,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Ciclo: ${crop.cycleDays} días • ${crop.season}',
                      style: TextStyle(
                        color: AppColors.mutedText(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _step = 1),
                child: const Text('Cambiar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        RegisterFieldCard(
          icon: Icons.map_outlined,
          title: 'Área de siembra',
          subtitle: 'Superficie en hectáreas',
          controller: _areaController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffix: 'ha',
          errorText: _errors['area'],
        ),
        const SizedBox(height: 16),
        RegisterFieldCard(
          icon: Icons.calendar_today_outlined,
          title: 'Fecha de siembra',
          subtitle: '¿Cuándo plantaste o cuándo plantarás?',
          controller: _dateController,
          keyboardType: TextInputType.datetime,
          errorText: _errors['fecha'],
          readOnly: true,
          onTap: _pickDate,
        ),
        const SizedBox(height: 16),
        RegisterFieldCard(
          icon: Icons.location_on_outlined,
          title: 'Ubicación',
          subtitle: 'Municipio o parcela',
          controller: _locationController,
          keyboardType: TextInputType.text,
          errorText: _errors['ubicacion'],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 1),
                child: const Text('Atrás'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_validateFields()) {
                    setState(() => _step = 3);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5D33),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final crop = _selectedCrop!;
    final harvestDate = _selectedDate!.add(Duration(days: crop.cycleDays));

    return Column(
      key: const ValueKey<int>(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          'Confirma tu registro',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Revisa que toda la información sea correcta',
          style: TextStyle(color: AppColors.mutedText(context)),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: crop.badgeColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(crop.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    crop.name,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(height: 30, color: AppColors.border(context)),
              _confirmRow(
                Icons.map_outlined,
                'Área',
                '${_areaController.text} hectáreas',
              ),
              _confirmRow(
                Icons.calendar_today_outlined,
                'Fecha de siembra',
                _dateController.text,
              ),
              _confirmRow(
                Icons.location_on_outlined,
                'Ubicación',
                _locationController.text,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.greenIconBackground(context),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _timelineRow('Inicio', _dateController.text),
                    const SizedBox(height: 8),
                    _timelineRow(
                      'Cosecha estimada',
                      DateFormat('dd / MM / yyyy').format(harvestDate),
                      valueColor: const Color(0xFF00C853),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 2),
                child: const Text('Modificar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5D33),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey<String>('success'),
      children: [
        const SizedBox(height: 80),
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: const Color(0xFF0D5D33),
            borderRadius: BorderRadius.circular(35),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 70,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          '¡Registrado!',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00C853),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tu cultivo de ${_selectedCrop?.name} se guardó localmente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.mutedText(context), fontSize: 16),
        ),
      ],
    );
  }

  Widget _confirmRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.greenText(context)),
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
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.greenText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.mutedText(context))),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.primaryText(context),
          ),
        ),
      ],
    );
  }
}
