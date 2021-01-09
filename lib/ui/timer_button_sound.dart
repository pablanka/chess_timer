part of 'timer_widget.dart';

class TimerButtonSound {
  Uint8List _buffer;
  final _player = FlutterSoundPlayer();

  TimerButtonSound() {
    _init();
  }

  void play() {
    _player.startPlayerFromBuffer(_buffer);
  }

  Future<void> _init() async {
    _buffer = await getAssetData('assets/sounds/timer_button.wav');
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }
}
