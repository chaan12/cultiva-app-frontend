import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/crop_record.dart';
import '../../../shared/state/app_scope.dart';
import '../../../shared/state/app_store.dart';
import '../../crop_register/screens/crop_register_screen.dart';
import '../../crop_tracking/screens/crop_tracking_screen.dart';
import '../../crop_tracking/services/crop_tracking_service.dart';
import '../widgets/crop_record_card.dart';
import 'crop_edit_screen.dart';

class MyCropsScreen extends StatelessWidget {
  const MyCropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, store),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.greenText(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cultivos activos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greenText(context),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _showHistory(context, store.cropHistory),
                        icon: const Icon(Icons.history),
                        label: Text('Historial (${store.cropHistory.length})'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (store.crops.isEmpty)
                    _buildEmptyState(context)
                  else
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: store.crops.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final crop = store.crops[index];
                        return CropRecordCard(
                          crop: crop,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CropTrackingScreen(crop: crop),
                              ),
                            );
                          },
                          onComplete: () =>
                              _markCropCompleted(context, store, crop),
                          onDelete: () => _deleteCrop(context, store, crop),
                          onEdit: () => _editCrop(context, crop),
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                  if (store.nextPendingEventCrop != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.agriculture_rounded,
                            color: AppColors.greenText(context),
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${store.nextPendingEventCrop!.name}: ${CropTrackingService.buildSummary(store.nextPendingEventCrop!).nextEventLabel}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText(context),
                              ),
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

  Widget _buildHeader(BuildContext context, AppStore store) {
    final topPadding = MediaQuery.paddingOf(context).top + 30;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D5D33),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Cultivos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gestión y seguimiento',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CropRegisterScreen(),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCard(store.activeCropsCount.toString(), 'Activos'),
              _statCard(store.totalHectares.toStringAsFixed(1), 'Hectáreas'),
              _statCard(store.upcomingEventsCount.toString(), 'Eventos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 48,
            color: AppColors.greenText(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes cultivos registrados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer cultivo para empezar a ver métricas reales.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedText(context)),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CropRegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5D33),
            ),
            child: const Text(
              'Registrar cultivo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markCropCompleted(
    BuildContext context,
    AppStore store,
    CropRecord crop,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar cultivo'),
        content: Text(
          '¿Quieres mover ${crop.name} al historial como cultivo completado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await store.completeCrop(crop.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${crop.name} movido al historial.')),
      );
    }
  }

  Future<void> _deleteCrop(
    BuildContext context,
    AppStore store,
    CropRecord crop,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar cultivo'),
        content: Text(
          '¿Quieres borrar ${crop.name}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await store.deleteCrop(crop.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${crop.name} eliminado.')));
    }
  }

  void _editCrop(BuildContext context, CropRecord crop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CropEditScreen(crop: crop)),
    );
  }

  void _showHistory(BuildContext context, List<CropRecord> history) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Historial de cultivos',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Aún no tienes cultivos completados.',
                      style: TextStyle(color: AppColors.mutedText(context)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: history.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final crop = history[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.border(context),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      crop.name,
                                      style: TextStyle(
                                        color: AppColors.primaryText(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF00A344),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${crop.formattedArea} • ${crop.locationName}',
                                style: TextStyle(
                                  color: AppColors.mutedText(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Completado el ${crop.completedAt == null ? crop.formattedSowingDate : '${crop.completedAt!.day.toString().padLeft(2, '0')}/${crop.completedAt!.month.toString().padLeft(2, '0')}/${crop.completedAt!.year}'}',
                                style: TextStyle(
                                  color: AppColors.mutedText(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
