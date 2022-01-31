package example

import (
	"context"
	"database/sql"
	"log"
	"testing"

	"ariga.io/atlas/sql/schema"
	"ariga.io/atlas/sql/sqlite"
	_ "github.com/mattn/go-sqlite3"
	"github.com/stretchr/testify/require"
)

func TestInspect(t *testing.T) {
	// Open a "connection" to sqlite.
	db, err := sql.Open("sqlite3", "file:example.db?cache=shared&_fk=1&mode=memory")
	if err != nil {
		log.Fatalf("failed opening db: %s", err)
	}
	// Create an "example" table for Atlas to inspect.
	ctx := context.Background()
	_, err = db.ExecContext(ctx, "create table example ( id int not null );")
	if err != nil {
		log.Fatalf("failed creating example table: %s", err)
	}
	// Open an Atlas driver.
	driver, err := sqlite.Open(db)
	if err != nil {
		log.Fatalf("failed opening atlas driver: %s", err)
	}
	// Inspect the created table.
	sch, err := driver.InspectSchema(ctx, "main", &schema.InspectOptions{
		Tables: []string{"example"},
	})
	if err != nil {
		log.Fatalf("failed inspecting schema: %s", err)
	}
	tbl, ok := sch.Table("example")
	require.True(t, ok, "expected to find example table")
	require.EqualValues(t, "example", tbl.Name)
	id, ok := tbl.Column("id")
	require.True(t, ok, "expected to find id column")
	require.EqualValues(t, &schema.ColumnType{
		Type: &schema.IntegerType{T: "int"}, // An integer type, specifically "int".
		Null: false,                         // The column has NOT NULL set.
		Raw:  "INT",                         // The raw type inspected from the DB.
	}, id.Type)
}
