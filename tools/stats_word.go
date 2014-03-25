package main

import(
	"fmt"
	"io"
	"io/ioutil"	
	"os"
	"strconv"
	"math"
	"unicode/utf8"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

//func toUtf8(iso8859_1_buf []byte) string {
//    buf := make([]rune, len(iso8859_1_buf))
//    for i, b := range iso8859_1_buf {
//        buf[i] = rune(b)
//    }
//    return string(buf)
//}

func main() {
	f, err := os.Open("de_DE.dict")
	check(err)
	defer f.Close()

	b := make([]byte, 1)	
	tmp := make(map[string] int)
	cnt := make(map[string] float64)
	sum := 0
	wc := 0
	for {
		_, err := f.Read(b)
		if err == io.EOF {
			break;
		} 
		if string(b) == "\n" {
			for k,c := range tmp {
				pct := float64(c)*100.0/float64(sum)
				_,prs := cnt[k]
				if !prs {
					cnt[k] = pct
				} else {
					cnt[k] = (cnt[k]+pct)/2.0
				}				
				tmp = make(map[string] int)
			}
			sum = 0			
			wc ++
			if (wc % (1000)) == 0 {
				fmt.Println( wc)
			}
			continue
		}
		b_s := string(b)
		_,prs := tmp[b_s]
		if !prs {
			tmp[b_s] = 1
		} else {
			tmp[b_s] ++
		}
		sum ++
	}

	out := ""
	for k,v := range cnt {
		fmt.Println(k,":",v)
		out += k+":"+strconv.Itoa(int(math.Ceil(v)))+"\n"
	}
	out_b := []byte(out)
	err = ioutil.WriteFile("de_DE.wstat", out_b, 0644)
	check(err)
	fmt.Println("done")
}
