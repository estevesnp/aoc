package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Card struct {
	value  int
	copies int
}

func main() {
	input, err := os.Open("../input.txt")
	if err != nil {
		panic(err)
	}
	defer input.Close()

	fmt.Println("RESULT:", solution(input))
}

func solution(input *os.File) int {
	cardMap := make(map[int]Card)
	n := 0

	scanner := bufio.NewScanner(input)
	for scanner.Scan() {
		n++
		cardMap[n] = Card{copies: 1, value: parseCard(scanner.Text())}
	}

	for i := 1; i <= n; i++ {
		r := cardMap[i].value + i
		for x := i + 1; x <= r && x <= n; x++ {
			c := cardMap[x]
			c.copies += cardMap[i].copies
			cardMap[x] = c
		}
	}

	counter := 0

	for _, c := range cardMap {
		counter += c.copies
	}

	return counter
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
				count++
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
