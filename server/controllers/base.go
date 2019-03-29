package controllers

import (
	"errors"

	"github.com/astaxie/beego"
)

//BaseController  基础控制
type BaseController struct {
	beego.Controller
}

//Abort 封装错误
func (c *BaseController) Abort(msg string) {
	c.Ctx.RenderMethodResult(errors.New(msg))
}
