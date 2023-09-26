package main_test

import (
	"database/sql"
	"testing"
	"time"

	_ "github.com/marcboeker/go-duckdb"
)

type T struct {
	*testing.T
}

type user struct {
	name    string
	age     int
	height  float64
	awesome bool
	bday    time.Time
}

func TestCRUD(t *testing.T) {
	tt := T{t}

	db, err := sql.Open("duckdb", "")
	tt.check(err)
	defer db.Close()

	tt.Run("ping", func(t *testing.T) {
		tt := T{t}
		tt.check(db.Ping())
	})

	tt.Run("create", func(t *testing.T) {
		tt := T{t}
		tt.check(db.Exec("CREATE OR REPLACE TABLE users(name TEXT, age INTEGER, height FLOAT, awesome BOOLEAN, bday DATE)"))
		tt.check(db.Exec("INSERT INTO users VALUES('jerry', 99, 1.91, true, '1970-01-01')"))
		tt.check(db.Exec("INSERT INTO users VALUES('kramer', 70, 1.85, true, '1951-01-23')"))
		tt.check(db.Exec("INSERT INTO users VALUES('newman', 70, 1.85, true, '1951-01-23')"))
	})

	tt.Run("read", func(t *testing.T) {
		tt := T{t}
		rows, err := db.Query(`
		SELECT name, age, height, awesome, bday
		FROM users
		WHERE (name = ? OR name = ?) AND age > ? AND awesome = ?`,
			"jerry", "kramer", 30, true,
		)
		tt.check(err)
		defer rows.Close()
		for rows.Next() {
			u := new(user)
			tt.check(rows.Scan(&u.name, &u.age, &u.height, &u.awesome, &u.bday))

			tt.Logf(
				"%s is %d years old, %.2f tall, bday on %s and has awesomeness: %t\n",
				u.name, u.age, u.height, u.bday.Format(time.RFC3339), u.awesome,
			)
		}
		tt.check(rows.Err())
	})

	tt.Run("update", func(t *testing.T) {
		tt := T{t}
		tt.check(db.Exec("UPDATE users SET name = 'jerry2' WHERE name = 'jerry'"))
	})

	tt.Run("delete", func(t *testing.T) {
		tt := T{t}
		res, err := db.Exec("DELETE FROM users")
		tt.check(err)

		ra, _ := res.RowsAffected()
		tt.Logf("Deleted %d rows\n", ra)
	})

}

func (t T) check(args ...interface{}) {
	err := args[len(args)-1]
	if err != nil {
		t.Fatal(err)
	}
}
