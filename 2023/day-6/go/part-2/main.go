package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	input, err := os.Open("../../input.txt")
	if err != nil {
		panic(err)
	}
	defer input.Close()

	fmt.Println("RESULT:", solution(input))
}

func solution(input *os.File) int {
	s := bufio.NewScanner(input)

	s.Scan()
	timeLn := s.Text()
	s.Scan()
	distLn := s.Text()

	time := convToNum(timeLn)
	dist := convToNum(distLn)

	return getHoldTime(time, dist)
}

func getHoldTime(time, dist int) int {
	count := 0

	for i := 0; i <= time; i++ {
		s := i
		t := time - i
		d := s * t

		if d > dist {
			count++
			continue
		}

		if count > 0 {
			break
		}
	}

	return count
}

func convToNum(line string) int {
	numStrs := strings.Fields(line)[1:]
	s := strings.Join(numStrs, "")

	num, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}

	return num
}
