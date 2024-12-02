package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
	"sync"
)

type mapping struct {
	dest   int
	source int
	len    int
}

type seedPair struct {
	seed int
	len  int
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

	pairs := genSeedPairs(seeds)
	maps := getMaps(s)

	return startLoop(pairs, maps)
}

func genSeedPairs(num []int) []seedPair {
	n := len(num)

	if n%2 != 0 {
		panic(fmt.Sprintf("there are %d nums, should be even: %+v", n, num))
	}

	res := []seedPair{}

	for i := 0; i < n-1; i += 2 {
		res = append(res, seedPair{seed: num[i], len: num[i+1]})
	}

	return res
}

func getMaps(s *bufio.Scanner) [][]mapping {
	maps := [][]mapping{}

	for {
		lines, over := scanZone(s)

		maps = append(maps, parseLines(lines))

		if over {
			break
		}
	}

	return maps
}

func startLoop(seedPairs []seedPair, maps [][]mapping) int {
	res := -1

	ch := make(chan int)
	wg := sync.WaitGroup{}
	wg.Add(len(seedPairs))

	for _, spair := range seedPairs {
		go func(sp seedPair) {
			defer wg.Done()

			res := -1
			for i := 0; i < sp.len; i++ {

				nextSeed := sp.seed + i

				for _, m := range maps {
					nextSeed = cmpSeed(nextSeed, m)
				}

				if res == -1 || nextSeed < res {
					res = nextSeed
				}
			}

			ch <- res
		}(spair)
	}

	go func() {
		wg.Wait()
		close(ch)
	}()

	for r := range ch {
		if res == -1 || r < res {
			res = r
		}
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
