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

	sum := 0

	for s.Scan() {
		nums := parseLine(s.Text())
		sum += processNums(nums)
	}

	return sum
}

func processNums(nums []int) int {
	rows := [][]int{nums}
	curr := nums

	for !numsFinished(curr) {
		r := parseNums(curr)
		rows = append(rows, r)
		curr = r
	}

	count := 0

	for _, r := range rows {
		count += r[len(r)-1]
	}

	return count
}

func numsFinished(nums []int) bool {
	for _, n := range nums {
		if n != 0 {
			return false
		}
	}
	return true
}

func parseNums(nums []int) []int {
	n := len(nums)
	res := make([]int, n-1)

	for i := 0; i < n-1; i++ {
		res[i] = nums[i+1] - nums[i]
	}

	return res
}

func parseLine(line string) []int {
	f := strings.Fields(line)
	nums := make([]int, len(f))

	var err error
	for i, s := range f {
		nums[i], err = strconv.Atoi(s)
		if err != nil {
			panic(err)
		}
	}

	return nums
}
