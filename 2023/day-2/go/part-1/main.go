package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

const (
	MAX_RED   = 12
	MAX_GREEN = 13
	MAX_BLUE  = 14
)

type Play struct {
	red   int
	green int
	blue  int
}

func main() {
	input, err := os.Open("../../input.txt")
	if err != nil {
		panic(err)
	}
	defer input.Close()

	fmt.Println("RESULT:", solution(input))
}

func solution(input *os.File) int {
	var count int

	scanner := bufio.NewScanner(input)
	for scanner.Scan() {
		count += parseGame(scanner.Text())
	}

	return count
}

func parseGame(g string) int {
	id, err := strconv.Atoi(g[strings.Index(g, " ")+1 : strings.Index(g, ":")])
	if err != nil {
		panic(err)
	}

	plays := parsePlays(g)

	for _, p := range plays {
		if p.red > MAX_RED || p.green > MAX_GREEN || p.blue > MAX_BLUE {
			return 0
		}
	}

	return id
}

func parsePlays(g string) []Play {
	ps := strings.Split(g[strings.Index(g, ":")+1:], ";")
	plays := make([]Play, len(ps))

	for i, play := range ps {
		cMap := map[string]int{"red": 0, "green": 0, "blue": 0}

		for c := range cMap {

			index := strings.Index(play, c)
			if index == -1 {
				continue
			}

			temp := strings.Split(play[:index-1], " ")
			n, err := strconv.Atoi(temp[len(temp)-1])
			if err != nil {
				panic(err)
			}

			cMap[c] = n
		}

		plays[i] = Play{red: cMap["red"], green: cMap["green"], blue: cMap["blue"]}
	}

	return plays
}
