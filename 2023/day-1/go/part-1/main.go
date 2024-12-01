package main

import (
	"bufio"
	"fmt"
	"os"
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
	scanner := bufio.NewScanner(input)

	var count int

	for scanner.Scan() {
		count += parseLine(scanner.Bytes())
	}

	return count
}

func parseLine(line []byte) int {
	var firstDigit, lastDigit int

	for i := 0; i < len(line); i++ {
		b := line[i]
		if b >= '0' && b <= '9' {
			firstDigit = int(b - '0')
			break
		}
	}

	for i := len(line) - 1; i >= 0; i-- {
		b := line[i]
		if b >= '0' && b <= '9' {
			lastDigit = int(b - '0')
			break
		}
	}

	return firstDigit*10 + lastDigit
}
