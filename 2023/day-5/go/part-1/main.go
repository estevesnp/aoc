package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

type mapping struct {
	dest   int
	source int
	len    int
}

func main() {
	input, err := os.Open("../input.txt")
	if err != nil {
		panic(err)
	}

	fmt.Println("RESULT:", solution(input))
}

func solution(input *os.File) int {
	s := bufio.NewScanner(input)

	// first line
	s.Scan()
	seeds := parseSeeds(s.Text())
	// skip empty line
	s.Scan()

	locations := startLoop(s, seeds)

	return slices.Min(locations)
}

func startLoop(s *bufio.Scanner, seeds []int) []int {
	nextSeeds := make([]int, len(seeds))
	copy(nextSeeds, seeds)

	for {
		lines, over := scanZone(s)

		maps := parseLines(lines)

		nextSeeds = unmapSeeds(nextSeeds, maps)

		if over {
			break
		}
	}

	return nextSeeds
}

func unmapSeeds(seeds []int, maps []mapping) []int {
	res := make([]int, len(seeds))

	for i, s := range seeds {
		res[i] = cmpSeed(s, maps)
	}

	return res
}

func cmpSeed(seed int, maps []mapping) int {
	for _, m := range maps {
		dif := seed - m.source
		if dif < 0 || dif > m.len-1 {
			continue
		}

		return m.dest + dif
	}

	return seed
}

func scanZone(s *bufio.Scanner) (lines []string, over bool) {
	lines = []string{}
	for s.Scan() {
		t := s.Text()
		if strings.Contains(t, "map:") {
			continue
		}
		if t == "" {
			return lines, false
		}

		lines = append(lines, t)
	}

	return lines, true
}

func parseSeeds(line string) []int {
	tmp := strings.TrimPrefix(line, "seeds: ")
	seedStrs := strings.Fields(tmp)
	seeds := []int{}

	for _, seed := range seedStrs {
		s, err := strconv.Atoi(seed)
		if err != nil {
			panic(err)
		}

		seeds = append(seeds, s)
	}

	return seeds
}

func parseLines(lines []string) []mapping {
	maps := []mapping{}

	for _, line := range lines {
		nums := strings.Split(line, " ")
		dest, err := strconv.Atoi(nums[0])
		if err != nil {
			panic(err)
		}
		source, err := strconv.Atoi(nums[1])
		if err != nil {
			panic(err)
		}
		length, err := strconv.Atoi(nums[2])
		if err != nil {
			panic(err)
		}

		m := mapping{
			dest:   dest,
			source: source,
			len:    length,
		}

		maps = append(maps, m)
	}

	return maps
}
