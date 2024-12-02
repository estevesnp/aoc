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
	s := bufio.NewScanner(input)

	s.Scan()
	timeLn := s.Text()
	s.Scan()
	distLn := s.Text()

	times := convToNums(timeLn)
	dists := convToNums(distLn)

	if len(times) != len(dists) {
		panic(fmt.Sprintf("len times (%d) != len dists (%d): %+v | %+v", len(times), len(dists), times, dists))
	}

	possibleVals := calcPossibleVals(times, dists)

	count := 1

	for _, arr := range possibleVals {
		count *= len(arr)
	}

	return count
}

func calcPossibleVals(times, dists []int) [][]int {
	res := make([][]int, len(times))

	for i, t := range times {
		res[i] = getHoldTimes(t, dists[i])
	}

	return res
}

func getHoldTimes(time, dist int) []int {
	poss := []int{}

	for i := 0; i <= time; i++ {
		s := i
		t := time - i
		d := s * t

		if d > dist {
			poss = append(poss, d)
			continue
		}

		if len(poss) > 0 {
			break
		}
	}

	return poss
}

func convToNums(line string) []int {
	numStrs := strings.Fields(line)[1:]

	nums := make([]int, len(numStrs))

	var err error
	for i, str := range numStrs {
		nums[i], err = strconv.Atoi(str)
		if err != nil {
			panic(err)
		}
	}
	return nums
}
