package main

import(
	"fmt"
	//"io"
	"bufio"
	"io/ioutil"
	"os"
	"strings"
	"strconv"
)

type Ref struct {
	key string
	fname string
}

const PATH = "../dicts/de_DE/"

func inArray(w string, a []string) int {
	for i,s := range(a) {
		if s == w {
			return i
		}
	}
	return -1
}

func main() {
	fname := "references.ref"
	r_b, err := ioutil.ReadFile(PATH+fname)
	if err != nil {
		fmt.Println("Error reading "+fname+"\nerr:",err)
		os.Exit(0)
	}
	refsRaw := string(r_b)
	tmp := strings.Split(refsRaw,"\n")
	refs := make(map[string] string)
	for _,s := range(tmp) {
		if s == "" {
			continue
		}
		t := strings.Split(s,":")
		refs[t[0]] = t[1]
	}
	
	fmt.Println("References read and parsed.")

	readio := bufio.NewReader(os.Stdin)

	for {
		fmt.Println("Enter the next word :")
		line, _, err := readio.ReadLine()
		if (err != nil) || (string(line) == "") {
			break;
		}
		word := string(line)
		if len([]rune(word)) < 3 {
			fmt.Println("Words need to have at least 3 letters.")
			continue
		}
		word = strings.ToUpper(word)
		word = strings.Trim(word,"\n\r")
		prefix := string([]rune(word)[0:3])
		dictName, pres := refs[prefix]
		if !pres {
			fmt.Println("No file associated with the prefix "+prefix)
			continue
		}
		fmt.Println(prefix, dictName)
		d_b, err := ioutil.ReadFile(PATH+dictName)
		if err != nil {
			fmt.Println("Error reading "+PATH+dictName+"\nerr:",err)
			os.Exit(0)
		}
		cntRaw := string(d_b)
		cnt := strings.Split(cntRaw,"\n")
		pos := inArray( word, cnt)
		if pos != -1 {
			fmt.Println(word+" is already in "+PATH+dictName+" at line "+strconv.Itoa(pos))
			continue
		}
		cnt = append(cnt, word)
		out := ""
		for _,s := range(cnt) {
			s = strings.Trim(s,"\n\r")
			if s != "" {
				out = out+s+"\n"
			}
		}
		err = ioutil.WriteFile(PATH+dictName,[]byte(out),0644)
		if err != nil {
			fmt.Println("error writing "+PATH+dictName+"\nerr :",err)
			os.Exit(0)
		}
	}
}
