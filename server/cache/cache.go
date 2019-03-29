package cache

import (
	"fmt"
	"music_server/structs"
	"sync"
	"time"

	"github.com/astaxie/beego"
)

var (
	cacheSearchTime   = 60
	cacheDownloadTime = 30
)

const (
	splitflg = ","
)

func init() {
	searchcachePvd := beego.AppConfig.Strings("searchcache_pvd")
	for _, v := range searchcachePvd {
		trigerSearchCache(v)
	}
	downloadPvd := beego.AppConfig.Strings("download_pvd")
	for _, v := range downloadPvd {
		trigerDownloadCache(v)
	}
	cacheSearchTime = beego.AppConfig.DefaultInt("searchtime", 60)
	cacheDownloadTime = beego.AppConfig.DefaultInt("dcachetime", 30)
	beego.Info(fmt.Sprintf("searchCachePvd %v downloadCachePvd %v  cacheSearchTime %d cacheDownloadTime %d", searchcachePvd, downloadPvd, cacheSearchTime, cacheDownloadTime))
}

//searchCache 查询缓存
type searchCache struct {
	key    string
	time   time.Time
	caches []*struct {
		page  int
		songs []*structs.CSong
	}
}

func (cache *searchCache) findCache(page int) []*structs.CSong {
	for _, cc := range cache.caches {
		if cc.page == page {
			return cc.songs
		}
	}
	return nil
}

func (cache *searchCache) pushCache(songs []*structs.CSong, page int) {
	for _, cc := range cache.caches {
		if cc.page == page {
			cc.songs = songs
			return
		}
	}
	cache.caches = append(cache.caches, &struct {
		page  int
		songs []*structs.CSong
	}{page: page, songs: songs})
}

//searchCacheManager 缓存管理
type searchCacheManager struct {
	sync.RWMutex
	key2Cache map[string]*searchCache
}

func (mg *searchCacheManager) findCache(key string, page int) []*structs.CSong {
	defer mg.RUnlock()
	mg.RLock()
	if cache, result := mg.key2Cache[key]; result {
		//过期了删掉
		if cache.time.Before(time.Now()) {
			return nil
		}
		return cache.findCache(page)
	}
	return nil
}

func (mg *searchCacheManager) pushCache(key string, songs []*structs.CSong, page int) {
	defer mg.Unlock()
	mg.Lock()
	cache, result := mg.key2Cache[key]
	if !result {
		cache = &searchCache{key: key, caches: make([]*struct {
			page  int
			songs []*structs.CSong
		}, 0, 5)}
		mg.key2Cache[key] = cache
	}
	cache.time = time.Now().Add(time.Duration(cacheSearchTime) * time.Minute)
	cache.pushCache(songs, page)
}

var (
	pvd2schMg = make(map[string]*searchCacheManager)
)

//UseSearchCache 是否使用缓存
func UseSearchCache(provider string) bool {
	_, result := pvd2schMg[provider]
	return result
}

//trigerSearchCache 生成缓存管理
func trigerSearchCache(provider string) {
	if _, result := pvd2schMg[provider]; !result {
		pvd2schMg[provider] = &searchCacheManager{key2Cache: make(map[string]*searchCache)}
	}
}

//FindSearchCache 查询缓存
func FindSearchCache(provider string, key string, page int) []*structs.CSong {
	if mg, result := pvd2schMg[provider]; result {
		return mg.findCache(key, page)
	}
	return nil
}

//PushSearchCache 使用缓存
func PushSearchCache(provider string, key string, songs []*structs.CSong, page int) {
	if mg, result := pvd2schMg[provider]; result {
		mg.pushCache(key, songs, page)
	}
}

//downloadCache 下载缓存
type downloadCache struct {
	time time.Time
	url  string
}

//downloadCacheManager 缓存管理
type downloadCacheManager struct {
	sync.RWMutex
	key2Cache map[string]*downloadCache
}

func (mg *downloadCacheManager) findCache(dlid string) string {
	defer mg.RUnlock()
	mg.RLock()
	if cache, result := mg.key2Cache[dlid]; result {
		//过期了删掉
		if cache.time.Before(time.Now()) {
			return ""
		}
		return cache.url
	}
	return ""
}

func (mg *downloadCacheManager) pushCache(dlid string, url string) {
	defer mg.Unlock()
	mg.Lock()
	cache, result := mg.key2Cache[dlid]
	if !result {
		cache = &downloadCache{url: url}
		mg.key2Cache[dlid] = cache
	}
	cache.time = time.Now().Add(time.Duration(cacheDownloadTime) * time.Minute)
}

var (
	pvd2dlMg = make(map[string]*downloadCacheManager)
)

//UseDownloadCache 是否使用缓存
func UseDownloadCache(provider string) bool {
	_, result := pvd2dlMg[provider]
	return result
}

//trigerDownloadCache 生成缓存管理
func trigerDownloadCache(provider string) {
	if _, result := pvd2dlMg[provider]; !result {
		pvd2dlMg[provider] = &downloadCacheManager{key2Cache: make(map[string]*downloadCache)}
	}
}

//FindDownloadCache 查询缓存
func FindDownloadCache(provider string, dlid string) string {
	if mg, result := pvd2dlMg[provider]; result {
		return mg.findCache(dlid)
	}
	return ""
}

//PushDownloadCache 使用缓存
func PushDownloadCache(provider string, dlid string, url string) {
	if mg, result := pvd2dlMg[provider]; result {
		mg.pushCache(dlid, url)
	}
}
