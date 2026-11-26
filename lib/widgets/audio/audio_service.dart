import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  Source? _currentSource;

  Future<void> setFile(String path, {bool isAsset = true}) async {
    await _player.stop();

    final cleanPath =
        isAsset ? path.replaceFirst(RegExp(r'^assets/'), '') : path;

    _currentSource =
        isAsset ? AssetSource(cleanPath) : DeviceFileSource(cleanPath);

    await _player.setSource(_currentSource!);
  }

  Future<void> play() async {
    if (_currentSource == null) return;
    await _player.resume();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
