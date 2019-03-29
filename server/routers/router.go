package routers

import (
	"music_server/controllers"

	"github.com/astaxie/beego"
)

func initMusic() beego.LinkNamespace {
	ctl := &controllers.MusicController{}
	return beego.NSNamespace("/music",
		beego.NSRouter("/search", ctl, "get:SearchMusic"),
		beego.NSRouter("/download", ctl, "get:DownloadMusic"),
	)
}

func init() {
	ns := beego.NewNamespace("/api",
		initMusic(),
	)
	beego.AddNamespace(ns)
}
