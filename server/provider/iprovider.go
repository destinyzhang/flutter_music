package provider

import (
	"fmt"
	"music_server/cache"
	"music_server/structs"

	"github.com/astaxie/beego"
)

const (
	//ErrCodeOk 成功
	ErrCodeOk = 0
	//ErrCodePvdNil 非法pvd
	ErrCodePvdNil = 1
	//ErrCodeParmInvalid 参数错误
	ErrCodeParmInvalid = 2
	//ErrCodeSearchFail 查询失败
	ErrCodeSearchFail = 3
	//ErrCodeDURLFail 生成下载链接失败
	ErrCodeDURLFail = 4
)

var (
	providerMap     = make(map[string]structs.IProvider)
	defaultPageSize = 20
	defaultPvd      = "nil"
)

func init() {
	defaultPageSize = beego.AppConfig.DefaultInt("pagesize", 20)
	defaultPvd = beego.AppConfig.DefaultString("defaultpvd", "nil")
	beego.Info(fmt.Sprintf("defaultPageSize %d defaultPvd %s", defaultPageSize, defaultPvd))
}

//RegProvider 注册
func RegProvider(provider structs.IProvider) {
	name := provider.Name()
	providerMap[name] = provider
}

//SearchSongDefault 查询
func SearchSongDefault(key string, page int) *structs.CSearchResult {
	return SearchSong(defaultPvd, key, page)
}

//SearchSong 查询
func SearchSong(provider string, key string, page int) *structs.CSearchResult {
	if key == "" || page < 1 {
		return &structs.CSearchResult{ErrorCode: ErrCodeParmInvalid, Key: key, Page: page, Provider: provider}
	}
	if p, r := providerMap[provider]; r {
		//是否有缓存
		useCache := cache.UseSearchCache(provider)
		if useCache {
			if ccSongs := cache.FindSearchCache(provider, key, page); ccSongs != nil {
				return &structs.CSearchResult{ErrorCode: ErrCodeOk, Key: key, Page: page, Provider: provider, More: len(ccSongs) >= defaultPageSize, Songs: ccSongs, Cache: true}
			}
		}
		if songs, more := p.SearchSong(key, page); songs != nil {
			if useCache {
				cache.PushSearchCache(provider, key, songs, page)
			}
			return &structs.CSearchResult{ErrorCode: ErrCodeOk, Key: key, Page: page, Provider: provider, More: more, Songs: songs, Cache: false}
		}
		return &structs.CSearchResult{ErrorCode: ErrCodeSearchFail, Key: key, Page: page, Provider: provider}
	}
	return &structs.CSearchResult{ErrorCode: ErrCodePvdNil, Key: key, Page: page, Provider: provider}
}

//DownloadURL 查询
func DownloadURL(provider string, song *structs.CSong) *structs.CDownloadResult {
	if song.DlID == "" {
		return &structs.CDownloadResult{ErrorCode: ErrCodeParmInvalid, Provider: provider, DlID: song.DlID}
	}
	if p, r := providerMap[provider]; r {
		//是否有缓存
		useCache := cache.UseDownloadCache(provider)
		if useCache {
			if url := cache.FindDownloadCache(provider, song.DlID); url != "" {
				return &structs.CDownloadResult{ErrorCode: ErrCodeOk, Provider: provider, DlID: song.DlID, URL: url, Cache: true}
			}
		}
		if url := p.DownloadURL(song); url != "" {
			if useCache {
				cache.PushDownloadCache(provider, song.DlID, url)
			}
			return &structs.CDownloadResult{ErrorCode: ErrCodeOk, Provider: provider, DlID: song.DlID, URL: url, Cache: false}
		}
		return &structs.CDownloadResult{ErrorCode: ErrCodeDURLFail, Provider: provider, DlID: song.DlID}
	}
	return &structs.CDownloadResult{ErrorCode: ErrCodePvdNil, Provider: provider, DlID: song.DlID}
}
