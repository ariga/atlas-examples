package example

import (
	"context"
	"database/sql"
	"log"
	"testing"

	"ariga.io/atlas/sql/schema"
	"ariga.io/atlas/sql/sqlite"
	"github.com/stretchr/testify/require"
)

// This test shows how to filter out destructive operations (drops of columns, tables, etc.)
// from a migration plan in Atlas.
func TestNonDestructiveChange(t *testing.T) {
	// Open a "connection" to sqlite.
	db, err := sql.Open("sqlite3", "file:example.db?cache=shared&_fk=1&mode=memory")
	if err != nil {
		log.Fatalf("failed opening db: %s", err)
	}
	// Create an "example" table for Atlas to inspect.
	ctx := context.Background()
	seed := `
create table example ( id int not null, name text );
create table drop_me (id int);
`
	_, err = db.ExecContext(ctx, seed)
	if err != nil {
		log.Fatalf("failed creating example table: %s", err)
	}
	// Open an Atlas driver.
	driver, err := sqlite.Open(db)
	if err != nil {
		log.Fatalf("failed opening atlas driver: %s", err)
	}
	// Define a desired state in Atlas DDL. In this state the "drop_me" table is dropped and the
	// "name" column is dropped from the "example" table.
	h := `
schema "main" {
}
table "example" {
	schema = schema.main
	column "id" {
		type = int
	}
	column "new" {
		type = int
	}
}
`
	// Inspect the existing state.
	existing, err := driver.InspectRealm(ctx, nil)
	require.NoError(t, err)
	// Get the desired state from HCL.
	var desired schema.Realm
	err = sqlite.UnmarshalHCL([]byte(h), &desired)
	require.NoError(t, err)
	// Calculate the diff. The diff contains the drop table and column changes.
	diff, err := driver.RealmDiff(existing, &desired)
	require.NoError(t, err)
	// Keep only non-destructive operations.
	nonDestructive := filterDestructive(diff)
	// Create an SQL plan from the filtered changes.
	plan, err := driver.PlanChanges(ctx, "change", nonDestructive)
	require.NoError(t, err)
	// Assert that the plan only contains the addition of the new column.
	require.Len(t, plan.Changes, 1)
	require.EqualValues(t, "ALTER TABLE `example` ADD COLUMN `new` int NOT NULL", plan.Changes[0].Cmd)
}

func filterDestructive(source []schema.Change) []schema.Change {
	var keep []schema.Change
	for _, change := range source {
		if destructive(change) {
			continue
		}
		switch c := change.(type) {
		case *schema.ModifySchema:
			c.Changes = filterDestructive(c.Changes)
		case *schema.ModifyTable:
			c.Changes = filterDestructive(c.Changes)
		}
		keep = append(keep, change)
	}
	return keep
}

func destructive(change schema.Change) bool {
	switch change.(type) {
	case *schema.DropSchema, *schema.DropTable, *schema.DropIndex, *schema.DropCheck,
		*schema.DropAttr, *schema.DropForeignKey, *schema.DropColumn:
		return true
	}
	return false
}
