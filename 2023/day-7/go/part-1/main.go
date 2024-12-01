package main

import (
	"bufio"
	"cmp"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

type handType int

const (
	HIGH handType = iota
	ONE
	TWO
	THREE
	FULL
	FOUR
	FIVE
)

type hand struct {
	cards string
	bet   int
	hType handType
}

var cMap = map[rune]int{
	'2': 1,
	'3': 2,
	'4': 3,
	'5': 4,
	'6': 5,
	'7': 6,
	'8': 7,
	'9': 8,
	'T': 9,
	'J': 10,
	'Q': 11,
	'K': 12,
	'A': 13,
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
	s := bufio.NewScanner(input)
	hands := []hand{}

	for s.Scan() {
		var err error
		h := hand{}
		f := strings.Fields(s.Text())

		h.cards = f[0]
		h.bet, err = strconv.Atoi(f[1])
		if err != nil {
			panic(err)
		}

		h.hType = getHandType(h.cards)

		hands = append(hands, h)
	}

	slices.SortFunc(hands, cmpHands)

	pot := 0

	for i, h := range hands {
		pot += (i + 1) * h.bet
	}

	return pot
}

func cmpHands(h1, h2 hand) int {
	c := cmp.Compare(h1.hType, h2.hType)
	if c != 0 {
		return c
	}

	hand1 := []rune(h1.cards)
	hand2 := []rune(h2.cards)

	for i, r1 := range hand1 {
		r2 := hand2[i]
		v1 := cMap[r1]
		v2 := cMap[r2]

		rc := cmp.Compare(v1, v2)
		if rc == 0 {
			continue
		}

		return rc
	}

	panic(fmt.Sprintf("hands shouldn't be the same: %+v | %+v", h1.cards, h2.cards))
}

func getHandType(h string) handType {
	m := map[rune]int{}

	for _, r := range h {
		m[r]++
	}

	switch len(m) {
	case 5:
		return HIGH
	case 4:
		return ONE

	case 3:
		for _, v := range m {
			if v == 3 {
				return THREE
			}
		}
		return TWO

	case 2:
		var fv int
		for _, v := range m {
			fv = v
			break
		}
		if fv == 1 || fv == 4 {
			return FOUR
		}

		return FULL

	default:
		return FIVE
	}
}
