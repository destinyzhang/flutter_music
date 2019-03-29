import 'package:flutter/material.dart';
import 'package:dl_music/pages/search.dart';
import 'package:dl_music/pages/download.dart';
import 'package:dl_music/pages/songs.dart';
import 'package:dl_music/pages/songsheet.dart';
import 'package:dl_music/storage/unit.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>  {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(Unit.instance);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(Unit.instance);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  color: Unit.instance.styleColor,
                ),
                title: Text(
                  '搜歌',
                  style: TextStyle(color: Unit.instance.styleColor),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.library_music,
                  color: Unit.instance.styleColor,
                ),
                title: Text(
                  '歌单',
                  style: TextStyle(color: Unit.instance.styleColor),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.music_video,
                  color: Unit.instance.styleColor,
                ),
                title: Text(
                  '歌曲',
                  style: TextStyle(color: Unit.instance.styleColor),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.arrow_downward,
                  color: Unit.instance.styleColor,
                ),
                title: Text(
                  '下载',
                  style: TextStyle(color: Unit.instance.styleColor),
                )),
          ],
          currentIndex: _currentIndex,
          onTap: (int index) {
            if (_currentIndex == index)
              return;
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.shifting,
        ),
        body: IndexedStack(
          children: <Widget>[
            SearchPage(),
            SongSheetPage(),
            SongsPage(),
            DownloadPage(),
          ],
          index: _currentIndex,
        )
    );
  }
}
