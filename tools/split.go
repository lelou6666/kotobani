package main

import(
	"fmt"
	"io"
	"io/ioutil"	
	"os"
	"strings"
	"strconv"
	"bufio"
)


type Ref struct {
	key string
	fname string
}

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
	validVocals := "AEIUOYÜÖÄ" 

	f, err := os.Open("de_DE.dict")
	check(err)
	defer f.Close()
	
	smallWords := ""
	currentWords := ""
	currentPrefix := "AAA"

	sum := 0
	smallSum := 0
	fileCount := 0
	reader := bufio.NewReader(f)
	references := make(map[int] Ref)
	for {
		s, e := reader.ReadString('\n')
		if e == io.EOF {
			break;
		} 
		s = strings.ToUpper(s)
		
		// remove accronymes
		if ! strings.ContainsAny(s, validVocals) {
			continue
		}
		
		switch len([]rune(s)) {
		case 2:
			continue
		case 3:
			smallWords += s
			smallSum ++
			continue
		default:
			if strings.HasPrefix(s,currentPrefix) {
				currentWords += s
			} else {			
				if currentWords != "" {
					fmt.Println("Saving "+currentPrefix,"(",sum," words, fname : ",fileCount,")")
					err = ioutil.WriteFile("./dicts/"+strconv.Itoa(fileCount), []byte(currentWords), 0644)
					if err != nil {
						fmt.Println("error writing "+"./dicts/"+strconv.Itoa(fileCount), err)
					} else {
						references[fileCount]=Ref{currentPrefix, strconv.Itoa(fileCount)}
						fileCount ++
					}
				}
				sum = 0;
				currentWords = s
				currentPrefix = string([]rune(s)[0:3])
			}
			sum ++
		}
	}
	fmt.Println("Saving small words (",smallSum," words, fname : ",fileCount,")")
	err = ioutil.WriteFile("./dicts/"+strconv.Itoa(fileCount), []byte(smallWords), 0644)
	if err != nil {
		fmt.Println("error writing ./dicts/"+strconv.Itoa(fileCount), err)
	}
	references[fileCount]=Ref{"OTHERS", strconv.Itoa(fileCount)}

	fmt.Println("Saving references ...")
	strRefs := ""
	for _,r := range(references) {
		strRefs = strRefs + r.key + ":" + r.fname + "\n"
	}
	err = ioutil.WriteFile("./dicts/references.json", []byte( strRefs), 0644)
	if err != nil {
		fmt.Println("error writing ./dicts/references.json", err)
	}
	fmt.Println("done")
}
