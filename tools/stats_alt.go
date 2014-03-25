package main

import(
	"fmt"
	"io"
	"io/ioutil"	
	"os"
	"encoding/json"
	"strings"
	"math"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func toUtf8(iso8859_1_buf []byte) string {
    buf := make([]rune, len(iso8859_1_buf))
    for i, b := range iso8859_1_buf {
        buf[i] = rune(b)
    }
    return string(buf)
}

func main() {
	f, err := os.Open("de_DE.dict")
	check(err)
	defer f.Close()

	b := make([]byte, 1)	
	cnt := make(map[string] int)
	sum := 0
	for {
		_, err := f.Read(b)
		if err == io.EOF {
			break;
		} 
		if string(b) == "\n" {
			continue
		}
		b_s := strings.ToUpper(toUtf8(b))
		_,prs := cnt[b_s]
		if !prs {
			cnt[b_s] = 1
		} else {
			cnt[b_s] ++
		}
		sum ++
		if (sum % (10*1024)) == 0 {
			fmt.Println( sum)
		}
	}
	out := make(map[string] int)

	div := float64(100.0/float64(sum))

	fmt.Println("SUM : ",sum)
	fmt.Println("DIV : ",div)

	for k,v := range cnt {
		out[k] = int(math.Max(10,math.Ceil(float64(v)*div)))
	}

	
	out_json, err := json.Marshal(out)
	check(err)
	out_b := []byte(out_json)
	err = ioutil.WriteFile("de_DE.fstat", out_b, 0644)
	check(err)
	fmt.Println("done")
}
