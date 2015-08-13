import std.stdio;
import std.typecons : Nullable;
import d2sqlite3;


void main() {
// Open a database in memory.
auto db = Database(":memory:");

// Create a table
auto cs = "CREATE TABLE person (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        score FLOAT
     )";
db.execute(cs);

// Populate the table

// Prepare an INSERT statement
auto statement = db.prepare(
	"INSERT INTO person (name, score)
     VALUES (:name, :score)"
	);

// Bind values one by one (by parameter name or index)
statement.bind(":name", "John");
statement.bind(2, 77.5);
statement.execute();

statement.reset(); // Need to reset the statement after execution.

// Bind muliple values at once
statement.bindAll("John", null);
statement.execute();

// Count the changes
assert(db.totalChanges == 2);

// Count the Johns in the table.
auto count = db.execute("SELECT count(*) FROM person WHERE name == 'John'")
	.oneValue!long;
assert(count == 2);

// Read the data from the table lazily
auto results = db.execute("SELECT * FROM person");
foreach (row; results)
{
	// Retrieve "id", which is the column at index 0, and contains an int,
	// e.g. using the peek function (best performance).
	auto id = row.peek!long(0);
	
	// Retrieve "name", e.g. using opIndex(string), which returns a ColumnData.
	auto name = row["name"].as!string;
	writeln(name);
	// Retrieve "score", which is at index 3, e.g. using the peek function,
	// using a Nullable type
	auto score = row.peek!(Nullable!double)(3);
	if (!score.isNull) {
		// ...
	}
}

// Read all the table in memory at once
auto data = RowCache(db.execute("SELECT * FROM person"));
foreach (row; data)
{
	auto id = row[0].as!long;
	auto last = row["name"].as!string;
	auto score = row[2].as!(Nullable!double);
	// etc.
}

}