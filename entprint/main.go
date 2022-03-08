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
				return nil, skip
			})
		}),
	); err != nil && !errors.Is(err, skip) {
		log.Fatalf("failed printing schema changes: %v", err)
	}
}
