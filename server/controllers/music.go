package controllers

import (
	"music_server/provider"
	"music_server/structs"
)

//MusicController  音乐服务
type MusicController struct {
	BaseController
}

//SearchMusic 查询歌曲
func (o *MusicController) SearchMusic() {
	key := o.GetString("key")
	pvd := o.GetString("pvd")
	page, _ := o.GetInt("page", 0)
	o.Data["json"] = provider.SearchSong(pvd, key, page)
	o.ServeJSON()

}

//DownloadMusic 下载歌曲
func (o *MusicController) DownloadMusic() {
	dlid := o.GetString("dlid")
	pvd := o.GetString("pvd")
	dresult := provider.DownloadURL(pvd, &structs.CSong{DlID: dlid})
	o.Data["json"] = dresult
	o.ServeJSON()
}
