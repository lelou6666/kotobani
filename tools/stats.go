package main

import(
	"fmt"
	"io"
	"io/ioutil"	
	"os"
	"encoding/json"
	"strings"
	"bufio"
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

	//b := make([]run, 1)	
	cnt := make(map[rune] int)
	sum := 0
	reader := bufio.NewReader(f)
	for {
		r, _, e := reader.ReadRune()
		if e == io.EOF {
			break;
		} 
		if string(r) == "\n" {
			continue
		}
		r_s := rune(strings.ToUpper(string(r)))
		_,prs := cnt[r_s]
		if !prs {
			cnt[r_s] = 1
		} else {
			cnt[r_s] ++
		}
		sum ++
		if (sum % (10*1024)) == 0 {
			fmt.Println( sum)
		}
	}
	out := make(map[rune] float64)

	div := float64(100.0/float64(sum))

	fmt.Println("SUM : ",sum)
	fmt.Println("DIV : ",div)

	for k,v := range cnt {
		out[k] = float64(v)*div
	}

	
	out_json, err := json.Marshal(out)
	check(err)
	out_b := []byte(out_json)
	err = ioutil.WriteFile("de_DE.fstat", out_b, 0644)
	check(err)
	fmt.Println("done")
}
