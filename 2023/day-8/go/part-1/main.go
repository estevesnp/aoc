package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type node struct {
	name  string
	lname string
	rname string
}

const (
	initialNode = "AAA"
	finalNode   = "ZZZ"
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

	nmap := map[string]node{}
	s.Scan()
	directions := []rune(s.Text())
	s.Scan()

	for s.Scan() {
		n := parseNode(s.Text())
		nmap[n.name] = n
	}

	return traverseMap(nmap, directions)
}

func parseNode(s string) node {
	n := node{}

	parts := strings.Split(s, " = ")
	if len(parts) != 2 {
		panic(fmt.Sprintf("parts (%+v) generated from %q should have len 2", parts, s))
	}

	n.name = parts[0]

	sides := strings.Trim(parts[1], "()")
	names := strings.Split(sides, ", ")
	if len(names) != 2 {
		panic(fmt.Sprintf("names (%+v) generated from %q should have len 2", names, sides))
	}

	n.lname = names[0]
	n.rname = names[1]

	return n
}

func traverseMap(nmap map[string]node, directions []rune) int {
	cur := nmap[initialNode]
	count := 0
	dirCount := 0

	for cur.name != finalNode {
		d := directions[dirCount]
		count++
		dirCount++
		if dirCount >= len(directions) {
			dirCount = 0
		}

		if d == 'L' {
			cur = nmap[cur.lname]
		} else {
			cur = nmap[cur.rname]
		}
	}

	return count
}
