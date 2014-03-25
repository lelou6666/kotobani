package main

import(
	"fmt"
	"io"
	"io/ioutil"	
	"os"
	"strings"
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
	word := ""
	wc := 0
	for {
		_, err := f.Read(b)
		if err == io.EOF {
			categorize(word)
			word = ""
			wc ++
			if (wc % (1000)) == 0 {
				fmt.Println( wc)
			}
			break;
		} 
		if string(b) == "\n" {
		}
		word += string(b)
	}
}
