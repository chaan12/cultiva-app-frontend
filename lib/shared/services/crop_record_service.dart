import '../models/crop_record.dart';
import 'local_database_service.dart';

class CropRecordService {
  const CropRecordService(this._databaseService);

  final LocalDatabaseService _databaseService;

  Future<List<CropRecord>> saveCrop(CropRecord crop) async {
    await _databaseService.saveCrop(crop);
    return _databaseService.loadCrops();
  }

  Future<List<CropRecord>> deleteCrop(String cropId) async {
    await _databaseService.deleteCrop(cropId);
    return _databaseService.loadCrops();
  }

  Future<List<CropRecord>> completeCrop(String cropId) async {
    final crops = await _databaseService.loadCrops();
    final crop = _findCrop(crops, cropId);
    if (crop == null) {
      return crops;
    }
    await _databaseService.saveCrop(
      crop.copyWith(isCompleted: true, completedAt: DateTime.now()),
    );
    return _databaseService.loadCrops();
  }

  Future<CropEventUpdateResult> markEventCompleted(
    String cropId,
    String eventId,
  ) {
    return _updateCompletedEvent(
      cropId,
      (crop) => <String>{...crop.completedEventIds, eventId}.toList(),
    );
  }

  Future<CropEventUpdateResult> unmarkEventCompleted(
    String cropId,
    String eventId,
  ) {
    return _updateCompletedEvent(
      cropId,
      (crop) => crop.completedEventIds.where((id) => id != eventId).toList(),
    );
  }

  Future<CropEventUpdateResult> _updateCompletedEvent(
    String cropId,
    List<String> Function(CropRecord crop) nextCompletedEventIds,
  ) async {
    final crops = await _databaseService.loadCrops();
    final crop = _findCrop(crops, cropId);
    if (crop == null) {
      return CropEventUpdateResult(crops: crops);
    }

    final updatedCrop = crop.copyWith(
      completedEventIds: nextCompletedEventIds(crop),
    );
    await _databaseService.saveCrop(updatedCrop);
    return CropEventUpdateResult(
      crops: await _databaseService.loadCrops(),
      updatedCrop: updatedCrop,
    );
  }

  CropRecord? _findCrop(List<CropRecord> crops, String cropId) {
    for (final crop in crops) {
      if (crop.id == cropId) {
        return crop;
      }
    }
    return null;
  }
}

class CropEventUpdateResult {
  const CropEventUpdateResult({required this.crops, this.updatedCrop});

  final List<CropRecord> crops;
  final CropRecord? updatedCrop;
}
