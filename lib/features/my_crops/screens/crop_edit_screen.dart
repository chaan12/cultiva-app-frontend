import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/crop_record.dart';
import '../../../shared/state/app_scope.dart';
import '../../../shared/widgets/cultiva_snackbar.dart';
import '../../crop_register/widgets/register_field_card.dart';

class CropEditScreen extends StatefulWidget {
  const CropEditScreen({super.key, required this.crop});

  final CropRecord crop;

  @override
  State<CropEditScreen> createState() => _CropEditScreenState();
}

class _CropEditScreenState extends State<CropEditScreen> {
  static final DateTime _minSowingDate = DateTime(2020);
  static final DateTime _maxSowingDate = DateTime(2100);
  static const double _maxAreaHa = 100000;

  bool _showSuccess = false;
  final _areaController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  Timer? _successTimer;
  Map<String, String> _errors = <String, String>{};

  @override
  void initState() {
    super.initState();
    _areaController.text = widget.crop.areaHa.toString();
    _selectedDate = widget.crop.sowingDate;
    _dateController.text = DateFormat('dd / MM / yyyy').format(widget.crop.sowingDate);
    _locationController.text = widget.crop.locationName;
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    _areaController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
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
    if (!_validateFields() || _selectedDate == null) {
      return;
    }
    final area = double.parse(_areaController.text.trim().replaceAll(',', '.'));
    
    final updatedCrop = widget.crop.copyWith(
      areaHa: area,
      sowingDate: _selectedDate!,
      locationName: _locationController.text.trim(),
    );

    await AppScope.of(context).updateCrop(updatedCrop);
    
    if (!mounted) {
      return;
    }
    setState(() => _showSuccess = true);
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context, updatedCrop);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showSuccess
                      ? _buildSuccessView()
                      : _buildForm(),
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
                'Editar cultivo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles de la plantación',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Modifica la información de tu cultivo de ${widget.crop.name}',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 25),
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
          subtitle: '¿Cuándo plantaste?',
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
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5D33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Guardar cambios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
          '¡Actualizado!',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00C853),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Los cambios en tu cultivo se guardaron correctamente.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }
}
