package main

import (
	_ "music_server/routers"

	"github.com/astaxie/beego"
)

func main() {
	beego.Run()
}
