package main

import (
	"context"
	"errors"
	"fmt"
	"io/ioutil"
	"log"

	atlas "ariga.io/atlas/sql/schema"
	"ariga.io/atlas/sql/sqlite"
	"atlasgo.io/entprint/ent"
	"entgo.io/ent/dialect"
	"entgo.io/ent/dialect/sql/schema"
	_ "github.com/mattn/go-sqlite3"
)

// An example program that shows how to print the HCL representation of the database schema
// of an Ent project. This example is a bit hacky, but it uses some useful features of the Ent
// migration infrastructure to access the desired schema from within a `DiffHook`.
//
// In this example, we use `client.Schema.WriteTo` to direct the SQL output to `ioutil.Discard`, and
// from within the DiffHook use `sqlite.MarshalHCL` to get the HCL representation of the desired schema.
// Other drivers (MySQL, PostgreSQL) have similar MarshalHCL functions if you want to use those.
func main() {
	skip := errors.New("skipping")
	client, err := ent.Open(dialect.SQLite, "file:ent?mode=memory&cache=shared&_fk=1")
	if err != nil {
		log.Fatalf("failed connecting to mysql: %v", err)
	}
	defer client.Close()
	ctx := context.Background()
	// Dump migration changes to /dev/null.
	if err := client.Schema.WriteTo(ctx, ioutil.Discard,
		schema.WithDiffHook(func(next schema.Differ) schema.Differ {
			return schema.DiffFunc(func(current, desired *atlas.Schema) ([]atlas.Change, error) {
				hcl, err := sqlite.MarshalHCL(desired)
				if err != nil {
					return nil, err
				}
				fmt.Println(string(hcl))
				// skip the actual diffing:
				return nil, skip
			})
		}),
	); err != nil && !errors.Is(err, skip) {
		log.Fatalf("failed printing schema changes: %v", err)
	}
}
