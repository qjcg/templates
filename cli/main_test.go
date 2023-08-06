package main

import "testing"

func TestGreet(t *testing.T) {
	got := greet()
	want := "Hello, world!"

	if got != want {
		t.Fatalf("want %v got %v", want, got)
	}
}
