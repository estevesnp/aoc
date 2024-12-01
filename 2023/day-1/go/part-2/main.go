package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

var numMap = map[string]int{
	"zero":  0,
	"one":   1,
	"two":   2,
	"three": 3,
	"four":  4,
	"five":  5,
	"six":   6,
	"seven": 7,
	"eight": 8,
	"nine":  9,
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
	scanner := bufio.NewScanner(input)

	var count int

	for scanner.Scan() {
		count += parseLine(scanner.Text())
	}

	return count
}

func parseLine(line string) int {
	indexNumMap := make(map[int]int)

	for numString := range numMap {
		numIndexes := findIndexes(line, numString)
		for _, index := range numIndexes {
			indexNumMap[index] = numMap[numString]
		}
	}

	for i, char := range line {
		if char >= '0' && char <= '9' {
			indexNumMap[i] = int(char - '0')
		}
	}

	s, b := len(line)-1, 0

	for k := range indexNumMap {
		if k < s {
			s = k
		}
		if k > b {
			b = k
		}
	}

	return indexNumMap[s]*10 + indexNumMap[b]
}

func findIndexes(s, substr string) []int {
	numIndexes := []int{}

	var pointer, index int

	for {
		index = strings.Index(s[pointer:], substr)
		if index == -1 {
			break
		}
		numIndexes = append(numIndexes, index+pointer)
		pointer += index + len(substr)
	}

	return numIndexes
}
