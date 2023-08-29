//go:build integration

package main

import (
	"testing"
)

func TestGetRandomJoke_Integration(t *testing.T) {
	joke, err := getRandomJoke(ChuckNorrisJokeURL)
	if err != nil {
		t.Fatal(err)
	}

	if joke == "" {
		t.Fatalf("returned the empty string")
	}

	t.Log(joke)
}
