import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

enum PlayerState { stopped, playing, paused }

enum NotifyValue { durationChange, positionMove, songChange, stateChange }

enum PlayMode { circle_provider, circle_song, random_source }

class SongInfo {
  SongInfo({this.songURL, this.songName, this.uniqueName, this.isLocal});

  String songURL;
  String songName;
  String uniqueName;
  bool isLocal;
}

abstract class ISongProvider {
  SongInfo getNextSong(PlayMode mode,bool next);

  void seekSong(SongInfo song);

  void inValidSong(SongInfo song);

}

typedef PlayerChangeListener(NotifyValue value);

class MiniPlayer {
  static MiniPlayer _instance;

  static MiniPlayer get instance {
    if (_instance == null) {
      _instance = MiniPlayer(PlayerMode.MEDIA_PLAYER);
      _instance.init();
    }
    return _instance;
  }

  MiniPlayer(this._mode);

  ISongProvider _songProvider;
  PlayMode _playMode = PlayMode.circle_provider;
  List<PlayerChangeListener> _notifyList =   List<PlayerChangeListener>();
  SongInfo _currentSong = SongInfo();
  PlayerMode _mode;
  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

   Future<int>  playerProvider({bool next =true}) async {
     SongInfo song = _songProvider?.getNextSong(_playMode, next);
     if (song != null)
       return await play(song);
     return 0;
   }

  void changePlayMod() {
    switch (_playMode) {
      case PlayMode.circle_provider:
        _playMode = PlayMode.circle_song;
        break;
      case PlayMode.circle_song:
        _playMode = PlayMode.random_source;
        break;
      case PlayMode.random_source:
        _playMode = PlayMode.circle_provider;
        break;
    }
  }

  void setProvider(ISongProvider provider) {
    if (provider == _songProvider)
      return;
    _songProvider = provider;
    _songProvider?.seekSong(_currentSong);
  }

  get playMode => _playMode;

  get timeProgressText {
    return _position != null
        ? '${positionText ?? ''} / ${durationText ?? ''}'
        : _duration != null ? durationText : '';
  }

  get timeProgress {
    return (_position != null
        && _duration != null
        && _position.inMilliseconds > 0
        && _position.inMilliseconds < _duration.inMilliseconds)
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;
  }
  ISongProvider get songProvider => _songProvider;

  get uniqueName => _currentSong.uniqueName ?? "";

  get name => _currentSong.songName ?? "";

  get url => _currentSong.songURL ?? "";

  get isLocal => _currentSong.isLocal ?? false;

  get mode => _mode;

  get duration => _duration ?? 0;

  get position => _position ?? 0;

  get isPlaying => _playerState == PlayerState.playing;

  get isPaused => _playerState == PlayerState.paused;

  get durationText =>
      _duration
          ?.toString()
          ?.split('.')
          ?.first ?? '';

  get positionText =>
      _position
          ?.toString()
          ?.split('.')
          ?.first ?? '';

  void _notify(NotifyValue value) {
    for (var listener in _notifyList) {
      try {
        listener(value);
      } catch (e) {}
    }
  }

  void addListener(PlayerChangeListener listener) {
    if (listener == null)
      return;
    _notifyList.add(listener);
  }

  void removeListener(PlayerChangeListener listener) {
    if (listener == null)
      return;
    _notifyList.remove(listener);
  }

  void dispose() {
    _notifyList.clear();
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
  }

  void init() {
    _audioPlayer =   AudioPlayer(mode: _mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (_duration == duration)
        return;
      _duration = duration;
      _notify(NotifyValue.durationChange);
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) {
          _position = p;
          _notify(NotifyValue.positionMove);
        });

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) async {
          _playerState = PlayerState.stopped;
          _position = _duration;
          if (playMode == PlayMode.circle_song)
             resume();
          else
             playerProvider();
        });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      _playerState = PlayerState.stopped;
      _duration =   Duration(seconds: 0);
      _position =   Duration(seconds: 0);
      _notify(NotifyValue.stateChange);
    });
  }

  Future<int> play(SongInfo info) async {
    if (info == null)
      return -1;
    await stop();
    _currentSong = info;
    _position =   Duration(seconds: 0);
    _notify(NotifyValue.songChange);
    return resume();
  }

  Future<int> resume() async {
    if (_playerState == PlayerState.playing)
      return 1;
    if (_currentSong.songURL == null || _currentSong.songURL.length == 0) {
      if (_songProvider != null)
        return playerProvider();
      return 0;
    }
    final playPosition = (_position != null
        && _duration != null
        && _position.inMilliseconds > 0
        && _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    try {
      final result = await _audioPlayer.play(
          _currentSong.songURL, isLocal: _currentSong.isLocal,
          position: playPosition);
      _playerState = PlayerState.playing;
      _notify(NotifyValue.stateChange);
      return result;
    } catch (e) {
      print("resume exception" + e.toString());
      if (_songProvider != null)
        _songProvider.inValidSong(_currentSong);
      playerProvider();
    }
    return -1;
  }

  Future<int> pause() async {
    if (_playerState == PlayerState.paused)
      return 1;
    final result = await _audioPlayer.pause();
    if (result == 1)
      _playerState = PlayerState.paused;
    _notify(NotifyValue.stateChange);
    return result;
  }

  Future<int> stop() async {
    if (_playerState == PlayerState.stopped)
      return 1;
    final result = await _audioPlayer.stop();
    if (result == 1) {
      _playerState = PlayerState.stopped;
      _position =   Duration();
    }
    _notify(NotifyValue.stateChange);
    return result;
  }
}
