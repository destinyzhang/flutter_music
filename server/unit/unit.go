package unit

import (
	"fmt"
	"io/ioutil"
	"math/rand"
	"net/http"
	"time"

	beegoLog "github.com/astaxie/beego"
)

//CreateURLRequest 创建requese
func CreateURLRequest(referer string, url string) *http.Request {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		beegoLog.Error("unit CreateURLRequest url:" + url + "error:" + err.Error())
		return nil
	}
	req.Header.Set("REFERER", referer)
	return req
}

//CheckURLRequest 检查
func CheckURLRequest(referer string, url string) bool {
	if req := CreateURLRequest(referer, url); req != nil {
		resp, err := (&http.Client{}).Do(req)
		if err != nil {
			beegoLog.Error("unit CheckURLRequest url:" + url + "error:" + err.Error())
			return false
		}
		defer resp.Body.Close()
		return resp.StatusCode == 200
	}
	return false
}

//HTTPRequest referer http请求
func HTTPRequest(referer string, url string) []byte {
	if req := CreateURLRequest(referer, url); req != nil {
		resp, err2 := (&http.Client{}).Do(req)
		if err2 != nil {
			beegoLog.Error("unit HTTPRequest url:" + url + "error:" + err2.Error())
			return nil
		}
		defer resp.Body.Close()
		bytes, err3 := ioutil.ReadAll(resp.Body)
		if err3 != nil {
			beegoLog.Error("unit HTTPRequest  ReadAll url:" + url + "error:" + err3.Error())
			return nil
		}
		return bytes
	}
	return nil
}

//RandInt32 随机数
func RandInt32(min, max int) int {
	if min > max {
		min, max = max, min
	}
	rand.Seed(time.Now().UnixNano())
	return min + rand.Intn(max-min+1)
}

//ErgodicMap 遍历map
func ErgodicMap(name string, mapResult map[string]interface{}) {
	for k, v := range mapResult {
		switch v.(type) {
		case map[string]interface{}:
			ErgodicMap(k, v.(map[string]interface{}))
		default:
			fmt.Printf("map:%s key:%s value:%v \n", name, k, v)
		}
	}
}
