package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	input, err := os.Open("../input.txt")
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
		count += parseCard(scanner.Text())
	}

	return count
}

func parseCard(c string) int {
	var winNums, pNums []int

	sepNums := strings.Split(c[strings.Index(c, ":")+1:], "|")

	winNums = getNums(strings.TrimSpace(sepNums[0]))
	pNums = getNums(strings.TrimSpace(sepNums[1]))

	count := 0

	for _, p := range pNums {
		for _, w := range winNums {
			if p == w {

				if count == 0 {
					count++
					break
				}
				count *= 2
				break
			}
		}
	}

	return count
}

func getNums(s string) []int {
	nums := []int{}
	split := strings.Split(s, " ")

	for _, n := range split {
		num, err := strconv.Atoi(n)
		if err != nil {
			continue
		}
		nums = append(nums, num)
	}

	return nums
}
