package provider

import (
	"encoding/json"
	"fmt"
	"music_server/structs"
	"music_server/unit"
	"strings"

	beegoLog "github.com/astaxie/beego"
)

var (
	searchURL      = "http://c.y.qq.com/soso/fcgi-bin/search_for_qq_cp?w=%s&format=json&p=%d&n=%d"
	downloadURL    = "http://dl.stream.qqmusic.qq.com/"
	downloadFormat = "%s%s%s.mp3?vkey=%s&guid=%d&fromtag=1"
	genKeyURL      = "http://base.music.qq.com/fcgi-bin/fcg_musicexpress.fcg?guid=%d&format=json&json=3"
	referer        = "http://m.y.qq.com"
	prefixes       = []string{"M800", "M500", "C400"}
)

func init() {
	RegProvider(&QQProvider{})
}

//qqSong qq歌曲结构体
type qqSearchResult struct {
	Msg  string `json:"message"`
	Code int    `json:"code"`
	Data struct {
		Keyword string `json:"keyword"`
		Song    struct {
			List []*qqSong `json:"list"`
		} `json:"song"`
	} `json:"data"`
}

//qqKey qq歌曲下载key
type qqKey struct {
	Code    int      `json:"code"`
	Sip     []string `json:"sip"`
	Thirdip []string `json:"thirdip"`
	Key     string   `json:"key"`
}

//qqSong qq歌曲结构体
type qqSong struct {
	Singers []*struct {
		Mid  string `json:"mid"`
		Name string `json:"name"`
	} `json:"singer"`
	Size128   float64 `json:"size128"`
	Songname  string  `json:"songname"`
	Songmid   string  `json:"songmid"`
	Interval  float64 `json:"interval"`
	Albumname string  `json:"albumname"`
}

func (song *qqSong) Cover2CSong() *structs.CSong {
	return &structs.CSong{
		Singer:    song.Singer(),
		Size:      song.Size128,
		Name:      song.Songname,
		DlID:      song.Songmid,
		Interval:  song.Interval,
		Albumname: song.Albumname,
		PicPath:   ""}
}

func (song *qqSong) Size() string {
	return fmt.Sprintf("%.2fMb", song.Size128/(1024*1024))
}

func (song *qqSong) Singer() string {
	var builder strings.Builder
	for _, v := range song.Singers {
		builder.WriteString(v.Name)
	}
	return builder.String()
}

//QQProvider 提供音乐搜索下载能力接口
type QQProvider struct {
}

//Cache 实现接口
func (provider *QQProvider) Cache() bool {
	return true
}

//Name 实现接口
func (provider *QQProvider) Name() string {
	return "qq"
}

//DownloadURL 实现接口
func (provider *QQProvider) DownloadURL(song *structs.CSong) string {
	key := unit.RandInt32(1000000000, 2000000000)
	url := fmt.Sprintf(genKeyURL, key)
	if bytes := unit.HTTPRequest(referer, url); bytes != nil {
		result := qqKey{}
		if err4 := json.Unmarshal(bytes, &result); err4 != nil {
			beegoLog.Warning("qq DownloadURL fail result:" + string(bytes))
			return ""
		}
		urls := make(map[string]int)
		urls[downloadURL] = 1
		for _, v := range result.Sip {
			urls[v] = 1
		}
		for _, v := range result.Thirdip {
			urls[v] = 1
		}
		for k := range urls {
			for _, prefix := range prefixes {
				durl := fmt.Sprintf(downloadFormat, k, prefix, song.DlID, result.Key, key)
				if unit.CheckURLRequest(referer, durl) {
					return durl
				}
			}
		}
	}
	return ""
}

//SearchSong 实现接口
func (provider *QQProvider) SearchSong(key string, page int) ([]*structs.CSong, bool) {
	url := fmt.Sprintf(searchURL, key, page, defaultPageSize)
	if bytes := unit.HTTPRequest(referer, url); bytes != nil {
		result := qqSearchResult{}
		if err4 := json.Unmarshal(bytes, &result); err4 != nil {
			beegoLog.Warning("qq SearchSong fail result:" + string(bytes))
			return nil, false
		}
		if result.Code != 0 {
			beegoLog.Warning("qq SearchSong fail result:" + result.Msg)
			return nil, false
		}
		slen := len(result.Data.Song.List)
		songs := make([]*structs.CSong, 0, slen)
		for _, v := range result.Data.Song.List {
			songs = append(songs, v.Cover2CSong())
		}
		return songs, slen >= defaultPageSize
	}
	return nil, false
}
