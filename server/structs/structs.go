package structs

//CSong 歌曲 统一结果
type CSong struct {
	Singer    string  `json:"singer"`
	Size      float64 `json:"size"`
	Name      string  `json:"name"`
	DlID      string  `json:"dlid"`
	Interval  float64 `json:"interval"`
	Albumname string  `json:"albumname"`
	PicPath   string  `json:"picpath"`
}

//CSearchResult 歌曲查询结果
type CSearchResult struct {
	ErrorCode int      `json:"errorcode"`
	Songs     []*CSong `json:"songs"`
	Key       string   `json:"key"`
	Page      int      `json:"page"`
	More      bool     `json:"more"`
	Provider  string   `json:"pvd"`
	Cache     bool     `json:"cache"`
}

//CDownloadResult 歌曲下载链接生成
type CDownloadResult struct {
	ErrorCode int    `json:"errorcode"`
	Provider  string `json:"pvd"`
	URL       string `json:"url"`
	DlID      string `json:"dlid"`
	Cache     bool   `json:"cache"`
}

//ISong 歌曲接口
type ISong interface {
	Cover2CSong() *CSong
}

//IProvider 提供音乐搜索下载能力接口
type IProvider interface {
	SearchSong(key string, page int) ([]*CSong, bool)
	DownloadURL(song *CSong) string
	Name() string
}
