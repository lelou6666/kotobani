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
	PATH := "../dicts/de_DE/"

	validVocals := "AEIUOYÜÖÄ" 

	f, err := os.Open("de_DE.dict")
	check(err)
	defer f.Close()
	
	fileCount := 0
	reader := bufio.NewReader(f)

	references := make(map[int] Ref)
	rawStats := make(map[rune] int)
	files :=make(map[string] string)
	cntWords := 0.0
	cntRunes := 0.0

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
			continue
		default:
			// stats
			cntWords ++
			for _,r := range([]rune(s)) {
				if r==rune('\n') {
					continue
				}
				_,prs := rawStats[r]
				if !prs {
					rawStats[r] = 1
				} else {
					rawStats[r] ++
				}
				cntRunes ++
			}			
			// split
			pre := string([]rune(s)[0:3]) 
			files[pre] = files[pre]+strings.Trim(s,"\n\r")+"\n"	
		}
		if (int(cntWords)%1000) == 0 {
			fmt.Println(cntWords,"words. Current : "+s)
		}
	}

	fileCount = 0
	for prefix, words := range(files) {
		fmt.Println("Saving "+prefix,"(",strings.Count(words,"\n")," words, fname : ",fileCount,")")
		err = ioutil.WriteFile(PATH+strconv.Itoa(fileCount), []byte(words), 0644)
		if err != nil {
			fmt.Println("error writing "+PATH+strconv.Itoa(fileCount), err)
		} else {
			references[fileCount]=Ref{prefix, strconv.Itoa(fileCount)}
			fileCount ++
		}
	}
	fmt.Println("Saving references ...")
	refGD := ""
	refRef := ""
	for _,r := range(references) {
		if refGD != "" {
			refGD +=","
		}
		refGD = refGD+"\""+r.key+"\":\""+r.fname+"\""
		refRef = refRef+""+r.key+":"+r.fname+"\n"
	}

	refGD = "var dictRefs =  {"+refGD+"}\n"

	err = ioutil.WriteFile(PATH+"references.gd", []byte(refGD), 0644)
	if err != nil {
		fmt.Println("error writing "+PATH+"references.gd", err)
	}

	err = ioutil.WriteFile(PATH+"references.ref", []byte(refRef), 0644)
	if err != nil {
		fmt.Println("error writing "+PATH+"references.ref", err)
	}

	statsGD := ""
	cntCurrent := 0
	for r,c := range(rawStats) {
		if c < 50 {
			continue
		}	
		c = c/100
		cntCurrent += c
		if statsGD != "" {
			statsGD += ","
		}
		statsGD = statsGD+strconv.Itoa(cntCurrent)+":\""+string(r)+"\""
	}	
	statsGD = "var dictStats = {"+statsGD+"}\n"
	statsGD = statsGD+"var maxRuneProbability = "+strconv.Itoa(cntCurrent)

	err = ioutil.WriteFile(PATH+"stats.gd", []byte(statsGD), 0644)
	if err != nil {
		fmt.Println("error writing "+PATH+"stats.gd", err)
	}

	fmt.Println("\ntotal :",cntWords,"words")
	fmt.Println("done")
}
