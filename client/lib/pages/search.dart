import 'package:flutter/material.dart';
import 'package:dl_music/api/music.dart';
import 'package:dl_music/structs/searchresult.dart';
import 'package:dl_music/structs/song.dart';
import 'package:dl_music/api/download.dart';
import 'package:dl_music/pages/toast.dart';
import 'package:dl_music/storage/unit.dart';
import 'package:dl_music/storage/storage.song.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchText = TextEditingController();
  ScrollController _scrollController =   ScrollController();
  bool isPerformingRequest = false;
  bool haveMore = true;
  bool selectAll = false;
  List<Song> songs =   List<Song>();
  String strKey = "";
  int page = 0;
  Set<String> selectSongs =   Set<String>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  Future<SearchResult> _requestMore(String key, int page) async =>
      MusicApi.search(key, page);

  void _reset() {
    strKey = "";
    selectAll = false;
    isPerformingRequest = false;
    haveMore = true;
    page = 0;
    songs.clear();
    selectSongs.clear();
  }

  _getMoreData() async {
    if (!this.haveMore || this.strKey.length == 0) return;
    if (!this.isPerformingRequest) {
      setState(() => this.isPerformingRequest = true);
      SearchResult result = await _requestMore(this.strKey, this.page + 1);
      if (this.isPerformingRequest) {
        setState(() {
          this.isPerformingRequest = false;
          if (result == null) {
            this.haveMore = false;
            ToastPage.show(ErrCode.errMsg(ErrCode.ErrCodeServer404));
          } else {
            if (result.errorcode == ErrCode.ErrCodeOk) {
              this.songs.addAll(result.songs);
              this.haveMore = result.more;
              this.page = result.page;
              this.selectAll = false;
            } else {
              this.haveMore = false;
              ToastPage.show(ErrCode.errMsg(result.errorcode));
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _reset();
    _scrollController.dispose();
    _searchText.dispose();
    super.dispose();
  }

  void _selectAll() {
    setState(() {
      selectAll = !selectAll;
      if (selectAll)
        for (Song song in songs)
          selectSongs.add(song.dlid);
      else
        selectSongs.clear();
    });
  }

  void _downloadSelect() {
    if (selectSongs.length == 0)
      return;
    int downCount = 0;
    for (String dlID in selectSongs) {
      int idx = songs.indexWhere((s) {
        return s.dlid == dlID;
      });
      if (idx < 0)
        continue;
      Song song = songs[idx];
      //两边都要检查
      if (!SongStorage.songDownload.songExist(song.dlid) && !SongStorage.songSave.songExist(song.dlid)) {
        ++downCount;
        SongStorage.songDownload.addSong(song);
      }
    }
    if (downCount > 0) {
      SongStorage.songDownload.save();
      Downloader.start();
    }
    ToastPage.show(downCount > 0 ? "$downCount首歌加入下载列表" : "请勿重复下载");
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (songs.length == index)
      return haveMore ? _buildProgressIndicator() : null;
    if (songs.length > index) {
      var song = songs[index];
      var selected = selectSongs.contains(song.dlid);
      return CheckboxListTile(
          value: selected,
          onChanged: (newValue) {
            setState(() {
              if (newValue) {
                selectSongs.add(song.dlid);
              } else {
                selectSongs.remove(song.dlid);
              }
            });
          },
          selected: selected,
          title: Text(song.name),
          subtitle: Text("${song.singer} ${song.getTime()} ${song.getSize()}"),
          activeColor: Unit.instance.styleColor);
    }
    return null;
  }

  Widget _buildBottomNavigationBar() {
    if (songs.length == 0)
      return null;
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.select_all,
              color: Unit.instance.styleColor,
            ),
            title: Text(
              selectAll ? '取消全选' : '全部选中',
              style: TextStyle(color: Unit.instance.styleColor),
            )),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.arrow_downward,
              color: Unit.instance.styleColor,
            ),
            title: Text(
              '下载选中',
              style: TextStyle(color: Unit.instance.styleColor),
            )),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.clear,
              color: Unit.instance.styleColor,
            ),
            title: Text(
              '重置搜索',
              style: TextStyle(color: Unit.instance.styleColor),
            )),
      ],
      type: BottomNavigationBarType.fixed,
      iconSize: 12,
      onTap: (idx) {
        switch (idx) {
          case 0:
            _selectAll();
            break;
          case 1:
            _downloadSelect();
            break;
          case 2:
            _searchText.text = "";
            _doSearch("");
            break;
        }
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  _doSearch(String key) {
    key = key.trim();
    if (key == strKey)
      return;
    setState(() {
      _reset();
      strKey = key;
      _getMoreData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          maxLength: 30,
          controller: _searchText,
          decoration: InputDecoration(
              hintText: '输入歌名或歌手',
              suffixIcon: IconButton(
                onPressed: () {
                  _doSearch(_searchText.text);
                },
                icon: Icon(Icons.search),
              )
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemBuilder: _listBuilder,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
