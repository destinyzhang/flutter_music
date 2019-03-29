import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dl_music/api/player.dart';
import 'package:dl_music/storage/unit.dart';

class PlayerWidget extends StatefulWidget {
  PlayerWidget({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return   _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  void _playerNotify(NotifyValue value) {
    if (value == NotifyValue.positionMove)
      setState(() {});
  }

  @override
  void initState() {
    super.initState();
    MiniPlayer.instance.addListener(_playerNotify);
  }

  void dispose() {
    MiniPlayer.instance.removeListener(_playerNotify);
    super.dispose();
  }

  String _getPlayModeTip() {
    switch (MiniPlayer.instance.playMode) {
      case PlayMode.circle_provider:
        return "循环播放";
      case PlayMode.circle_song:
        return "单曲循环";
      case PlayMode.random_source:
        return "随机播放";
    }
    return "";
  }

  IconData _getPlayModeIconData() {
    switch (MiniPlayer.instance.playMode) {
      case PlayMode.circle_provider:
        return Icons.loop;
      case PlayMode.circle_song:
        return Icons.data_usage;
      case PlayMode.random_source:
        return Icons.all_inclusive;
    }
    return Icons.all_inclusive;
  }

  SizedBox _getSizedBox(double height, double width, Widget child) {
    return SizedBox(
      height: height,
      width: width,
      child: child,
    );
  }
  List<Widget> _buildControlWidget() {
    double _btnSize = 30;

    List<Widget> list = List<Widget>();
    list.add(IconButton(
        padding: const EdgeInsets.only(),
        onPressed: MiniPlayer.instance.isPlaying
            ? () => _pause()
            : () =>
            _play(),
        iconSize: _btnSize,
        icon:   Icon(
            MiniPlayer.instance.isPlaying ? Icons.pause : Icons
                .play_arrow),
        color: Unit.instance.playerColor));
    list.add(IconButton(
        padding: const EdgeInsets.only(),
        onPressed: MiniPlayer.instance.isPlaying ||
            MiniPlayer.instance.isPaused ? () => _stop() : null,
        iconSize: _btnSize,
        icon:   Icon(Icons.stop),
        color: Unit.instance.playerColor));
    list.add(IconButton(
        padding: const EdgeInsets.only(),
        onPressed: () {
          setState(() {
            MiniPlayer.instance.changePlayMod();
          });
        },
        iconSize: _btnSize,
        icon:   Icon(_getPlayModeIconData()),
        tooltip: _getPlayModeTip(),
        color: Unit.instance.playerColor));
    if (MiniPlayer.instance.songProvider != null &&
        MiniPlayer.instance.playMode != PlayMode.circle_song) {
      list.insert(0, IconButton(
        padding: const EdgeInsets.only(),
        onPressed: () => MiniPlayer.instance.playerProvider(next: false),
        iconSize: _btnSize,
        icon:   Icon(Icons.arrow_back),
        color: Unit.instance.playerColor,));
      list.add(IconButton(
          padding: const EdgeInsets.only(),
          onPressed: () => MiniPlayer.instance.playerProvider(),
          iconSize: _btnSize,
          icon:   Icon(Icons.arrow_forward),
          color: Unit.instance.playerColor));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(),
      decoration:   BoxDecoration(
        border:   Border.all(width: 2.0, color: Unit.instance.playerColor),
        color: Colors.white,
        borderRadius:   BorderRadius.all(  Radius.circular(10.0)),
      ),
      height: 75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Text(
                  MiniPlayer.instance.name + " " +
                      MiniPlayer.instance.timeProgressText + "  ",
                  style:   TextStyle(fontSize: 15.0),
                ),
                _getSizedBox(18, 18, Stack(
                  children: [
                      CircularProgressIndicator(
                      value: 1.0,
                      valueColor:   AlwaysStoppedAnimation(
                          Unit.instance.backColorTwo),
                    ),
                      CircularProgressIndicator(
                      value: MiniPlayer.instance.timeProgress,
                      valueColor:   AlwaysStoppedAnimation(
                          Unit.instance.playerColor),
                    ),
                  ],
                ),),
              ]
          ),
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildControlWidget(),
          ),
        ],
      ),
    );
  }

  void _play() async {
    MiniPlayer.instance.resume().then((value) {
      setState(() {});
    });
  }

  void _pause() async {
    MiniPlayer.instance.pause().then((value) {
      setState(() {});
    });
  }

  void _stop() async {
    MiniPlayer.instance.stop().then((value) {
      setState(() {});
    });
  }
}
