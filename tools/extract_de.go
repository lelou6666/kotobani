package main

import(
	"fmt"
	"io/ioutil"
	"io"
	"bufio"
	"os"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func isAlpha(b byte) bool  {
	if ((b >= 'A') && (b <='Z')) || ((b >='a') && (b <= 'z')) || ((b >= 160) && (b <= 255)) {
		return true
	} 
	return false
}	 

func main() {
	f, err := os.Open("de_DE.rws")
	check(err)
	defer f.Close()

	out := ""
	inExtra := false
	inWord := false
	cnt := 0
	reader := bufio.NewReader(f)
	for {
		b, e := reader.ReadByte()
		if e == io.EOF {
			break;
		} 
		switch {
		case ! isAlpha(b) :
			if (! inWord) || (inExtra) {
				inExtra = false
			} else if inWord {
				inWord = false
				inExtra = true
				out = out+"\n"
			} 
		case isAlpha(b):
			if (inWord) || ((!inWord) && (!inExtra)) {
				out = out + string(b)
				inWord = true
			} else {
				inExtra = true
			}
		}	
		cnt ++
		if cnt%(10*1024) == 0 {
			fmt.Println( cnt)
		}			
	}
	out_b := []byte(out)
	err = ioutil.WriteFile("de_DE.dict", out_b, 0644)
	check(err)
	fmt.Println("done")
}
