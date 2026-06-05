import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../state/app_scope.dart';

class CultivaSoundService {
  const CultivaSoundService._();

  static Future<void> tap(BuildContext context) {
    return _play(context, SystemSoundType.click);
  }

  static Future<void> selection(BuildContext context) {
    return _play(context, SystemSoundType.click);
  }

  static Future<void> success(BuildContext context) {
    return _play(context, SystemSoundType.alert);
  }

  static Future<void> registrationComplete(BuildContext context) async {
    if (!_canPlay(context)) {
      return;
    }
    try {
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // System sounds are device-dependent; ignore failures silently.
    }
  }

  static Future<void> error(BuildContext context) {
    return _play(context, SystemSoundType.alert);
  }

  static Future<void> _play(BuildContext context, SystemSoundType sound) async {
    if (!_canPlay(context)) {
      return;
    }
    try {
      await SystemSound.play(sound);
    } catch (_) {
      // System sounds are device-dependent; ignore failures silently.
    }
  }

  static bool _canPlay(BuildContext context) {
    try {
      return !AppScope.of(context).settings.silentMode;
    } catch (_) {
      return true;
    }
  }
}
