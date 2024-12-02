package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

type MatrixNum struct {
	value int
	x     int
	y     int
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
	m := make([][]byte, 0)

	scanner := bufio.NewScanner(input)
	for scanner.Scan() {
		m = append(m, []byte(scanner.Text()))
	}

	return parseMatrix(m)
}

func parseMatrix(m [][]byte) int {
	count := 0
	for y := range m {
		count += parseRow(m, y)
	}

	return count
}

func parseRow(m [][]byte, y int) int {
	rowCount := 0
	re := regexp.MustCompile(`\*`)
	indexes := re.FindAllIndex(m[y], -1)

	for _, i := range indexes {
		x := i[0]
		nums := findNums(m, x, y)
		rowCount += filterNums(nums)
	}

	return rowCount
}

func findNums(m [][]byte, x, y int) []MatrixNum {
	nums := []MatrixNum{}

	xRelToCheck := []int{0}
	yRelToCheck := []int{0}

	if x > 0 {
		xRelToCheck = append(xRelToCheck, -1)
	}
	if y > 0 {
		yRelToCheck = append(yRelToCheck, -1)
	}
	if x < len(m[y])-1 {
		xRelToCheck = append(xRelToCheck, 1)
	}
	if y < len(m)-1 {
		yRelToCheck = append(yRelToCheck, 1)
	}

	for _, relY := range yRelToCheck {
		cY := y + relY
		for _, relX := range xRelToCheck {
			if relY == 0 && relX == 0 {
				continue
			}
			cX := x + relX
			char := m[cY][cX]

			if char < '0' || char > '9' {
				continue
			}

			nums = append(nums, findMatrixNum(m[cY], cX, cY))
		}
	}

	return nums
}

func findMatrixNum(r []byte, x, y int) MatrixNum {
	i := x
	f := x

	for ; i-1 >= 0; i-- {
		if r[i-1] < '0' || r[i-1] > '9' {
			break
		}
	}

	for ; f+1 < len(r); f++ {
		if r[f+1] < '0' || r[f+1] > '9' {
			break
		}
	}

	val, err := strconv.Atoi(string(r[i : f+1]))
	if err != nil {
		panic(err)
	}

	return MatrixNum{value: val, x: i, y: y}
}

func filterNums(nums []MatrixNum) int {
	numSet := []MatrixNum{}

	for _, n := range nums {
		found := false
		for _, ns := range numSet {
			if ns.x == n.x && ns.y == n.y {
				found = true
				break
			}
		}
		if !found {
			numSet = append(numSet, n)
		}
	}

	if len(numSet) != 2 {
		return 0
	}

	return numSet[0].value * numSet[1].value
}
