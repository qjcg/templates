package main

import (
	"fmt"
	"log"

	"github.com/bitfield/script"
)

const (
	ChuckNorrisJokeURL = `https://api.chucknorris.io/jokes/random`
)

func getRandomJoke(url string) (string, error) {
	return script.Get(url).JQ(".value").Replace(`"`, "").String()
}

func main() {
	joke, err := getRandomJoke(ChuckNorrisJokeURL)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(joke)
}
