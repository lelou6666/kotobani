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
	rawStats := make(map[rune] int)
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
			smallWords += s
			smallSum ++
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

	refCSV := ""
	for _,r := range(references) {
		refCSV = refCSV+r.key+","+r.fname+"\n"
	}

	err = ioutil.WriteFile("./dicts/references.csv", []byte(refCSV), 0644)
	if err != nil {
		fmt.Println("error writing ./dicts/references.txt", err)
	}

	statsCSV := ""
	cntCurrent := 0
	for r,c := range(rawStats) {
		if c < 50 {
			continue
		}
		cntCurrent += c
		statsCSV = statsCSV+string(r)+","+strconv.Itoa(cntCurrent)+"\n"
	}	

/*
// using percents is nice and fun but it involves plenty of 
// float64s. Using actual raw numbers doesn't change the algorythm and
// involves only ints, thus making it faster overall.

	rStatsCSV := ""

	wordStats := make(map[rune] float64)
	runeStats := make(map[rune] float64)
	pctWord := 100.0/float64(cntWords)
	pctRune := 100.0/float64(cntRunes)
	fmt.Println("Finalizing Stats. Percents : ",pctWord,pctRune)
	for r,c := range(rawStats) {
		wordStats[r] = float64(c)*pctWord
		runeStats[r] = float64(c)*pctRune
	}

	for r,c := range(wordStats) {
		wStatsCSV = wStatsCSV+string(r)+","+strconv.Ftoa(c)+"\n"
	}

	err = ioutil.WriteFile("./dicts/wstats.csv", byte(wStats), 0644)
	if err != nil {
		fmt.Println("error writing ./dicts/wstat.json", err)
	}
	for r,c := range(wordStats) {
		rStatsCSV = rStatsCSV+string(r)+","+strconv.Ftoa(c)+"\n"
	}
*/	


	err = ioutil.WriteFile("./dicts/stats.csv", []byte(statsCSV), 0644)
	if err != nil {
		fmt.Println("error writing ./dicts/stats.csv", err)
	}

	fmt.Println("done")
}
