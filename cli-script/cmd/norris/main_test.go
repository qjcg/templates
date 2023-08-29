package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func newTestServer() *httptest.Server {
	resp := []byte(`{
"icon_url" : "https://assets.chucknorris.host/img/avatar/chuck-norris.png",
"id" : "NQ68GCB8TdOADmMKH-7hgA",
"url" : "https://api.chucknorris.io/jokes/NQ68GCB8TdOADmMKH-7hgA",
"value" : "Taxi drivers pay Chuck Norris when he gets in their cabs."
}`)

	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write(resp)
	}))
}

func TestGetRandomJoke(t *testing.T) {
	ts := newTestServer()
	defer ts.Close()

	joke, err := getRandomJoke(ts.URL)
	if err != nil {
		t.Fatal(err)
	}

	if joke == "" {
		t.Fatalf("returned the empty string")
	}

	t.Log(joke)
}
