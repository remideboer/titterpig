import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isMuted = false;

  static Future<void> playRollSound() async {
    if (!_isMuted) {
      await _player.play(AssetSource('sounds/dice_roll.mp3'));
    }
  }

  static void toggleMute() {
    _isMuted = !_isMuted;
  }

  static bool get isMuted => _isMuted;
} 