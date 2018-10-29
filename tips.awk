#
# Loden Henning
# GROK Lab 2018
#
# This function takes an error code and returns the corresponding tip
#

# Codes are structured in the form "00-000" where the first two digits are the block number and the following three are the error
function tip(code){
	printf "• ";
switch (code){
    # BLOCK 1: SELECT, SHOW, USE, INSERT, UPDATE, DELETE, CREATE
    case "01-001":
		return "Hmmm, to get information from tables, try starting your query with SELECT.";
    case "01-002":
		return "All command statements go at the beginning of the line. Double check SELECT is the first word of your query.";
    case "01-003":
		return "Your query only needs to have one SELECT statement.";
    case "01-004":
		return "Whoops! It looks like you have SELECT and FROM statements when you don't need them.";
    case "01-005":
		return "It looks like you forgot a FROM statement. Your query should be set up as SELECT table1.column FROM table1 ... ;";
    case "01-006":
		return "You only need one FROM statement in your query. If you want data from mulitple tables, try a JOIN statement.";
    case "01-007":
		return "Whoops! It looks like you have a FROM statement when you don't need it.";
    case "01-008":
		return "Whoops! It looks like you have a SELECT statement when you don't need it.";
    case "01-009":
		return "Hmmm, to see a list of databases or tables, try starting your query with SHOW.";
    case "01-010":
		return "All command statements go at the beginning of the line. Double check SHOW is the first word of your query.";
    case "01-011":
		return "Your query only needs to have one SHOW statement.";
    case "01-012":
		return "Whoops! It looks like you have a SHOW statement when you don't need it.";
    case "01-013":
		return "Hmmm, to start interacting with a database, try starting your query with USE.";
    case "01-014":
		return "All command statements go at the beginning of the line. Double check USE is the first word of your query.";
    case "01-015":
		return "Your query only needs to have one USE statement.";
    case "01-016":
		return "Whoops! It looks like you have a USE statement when you don't need it.";
    case "01-017":
		return "Hmmm, to insert a new record into a table, try starting your query with INSERT INTO.";
    case "01-018":
		return "All command statements go at the start of the line. Double check INSERT INTO is the beginning of your query.";
    case "01-019":
		return "Your query only needs to have one INSERT statement.";
	case "01-020":
		return "Whoops! It looks like you have an INSERT statement when you don't need it.";
    case "01-021":
		return "Hmmm, to modify existing records in a table, try starting your query with UPDATE.";
    case "01-022":
		return "All command statements go at the beginning of the line. Double check UPDATE is the first word of your query.";
    case "01-023":
		return "Your query only needs to have one UPDATE statement.";
    case "01-024":
		return "Whoops! It looks like you have an UPDATE statement when you don't need it.";
    case "01-025":
		return "Hmmm, to delete existing records in a table, try starting your query with DELETE FROM.";
    case "01-026":
		return "All command statements go at the start of the line. Double check DELETE FROM is the beginning of your query.";
    case "01-027":
		return "Your query only needs to have one DELETE statement.";
    case "01-028":
		return "Whoops! It looks like you have a DELETE statement when you don't need it.";
    case "01-029":
		return "Hmmm, to create a new database or table, try starting your query with CREATE.";
    case "01-030":
		return "All command statements go at the beginning of the line. Double check CREATE is the first word of your query.";
    case "01-031":
		return "Your query only needs to have one CREATE statement.";
    case "01-032":
		return "Whoops! It looks like you have a CREATE statement when you don't need it.";
    case "01-033":
		return "If you only want rows that have a unique column value, try starting your query with SELECT DISTINCT.";
    case "01-034":
		return "FROM should be followed by a table you are calling colums from. Double check the word after your FROM.";
    case "01-035":
		return "SHOW should be followed by either 'databases' or 'tables'. Make sure you query for what you want to see.";
    case "01-036":
		return "USE should be followed by the name of the database you want to use. To see a list of databases, try 'SHOW databases'.";
	case "01-037":
		return "The structure when you want to is: 'INSERT INTO [...]'. Make sure your query follows this.";
	case "01-038":
		return "The structure of an insert is: 'INSERT INTO <table> ...'. Take another look at the table in your query.";
	case "01-039":
		return "UPDATE should be followed by the name of the table that contains the records you are modifying (e.g. UPDATE <table>).";
	case "01-040":
		return "The structure of an update is: 'UPDATE <table> SET <col1> = <val1>, <col2> = ... WHERE <col> = <condition>;'. Make sure SET is where it should be in your query.";
	case "01-041":
		return "The structure of a delete is: 'DELETE FROM <table> WHERE <col> = <condition>;'. It looks like you forgot the FROM.";
	case "01-042":
		return "The structure of a delete is: 'DELETE FROM <table> WHERE <col> = <condition>;'. Take another look at the table in your query.";
	case "01-043":
		return "CREATE should be followed by either DATABASE or TABLE depending on what are are creating. Make sure your query follows this rule.";
	case "01-044":
		return "The structure of a create is: 'CREATE DATABASE|TABLE <name> ...'. Take another look at the name you are giving.";

    # BLOCK 2: SELECT columns, CREATE columns and datatypes, INSERT columns and values
    case "02-001":
		return "Make sure you requested all the columns you need.";
    case "02-002":
		return "Whoops! It looks like you requested a column that you don't need or you misspelled one that you do. Remember, it's 'table.column'.";
    case "02-003":
		return "Oops! Make sure you only request each column once.";
    case "02-004":
		return "Make sure all your columns are accompanied by a table. It looks like you have something that doesn't follow the structure: table.column .";
	case "02-005":
		return "CREATE TABLE queries should have one set of parentheses. Make sure your query matches the structure: 'CREATE TABLE <name> (<col1> <datatype>, <col2> <datatype>, ...);'.";
	case "02-006":
		return "Your query should be structured like: 'CREATE TABLE <name> (<col1> <datatype>, <col2> <datatype>, ...);'. Make sure your columns and datatypes match this structure and are in the order specified in the prompt.";
	case "02-007":
		return "Double check the columns you listed. Make sure they're the ones you need, they don't have spelling mistakes, and  they're in the same order as the prompt.";
	case "02-008":
		return "Double check the datatypes you listed with your columns. Make sure they make sense for their associated column and check for spelling mistakes.";
	case "02-009":
		return "Your query should be structured like: 'CREATE TABLE <name> (<col1> <datatype>, <col2> <datatype>, ...);'. Make sure you have all the columns and datatypes you need.";
	case "02-010":
		return "Think about adding a VALUES statement to your query: 'INSERT INTO [ ... ] VALUES (val1, val2, etc.);'.";
	case "02-011":
		return "It looks like you have a VALUES statement you dont need. VALUES should only appear once in INSERT statements.";
	case "02-012":
		return "Make sure the data you are inserting into the columns are enclosed in parentheses: 'INSERT INTO table (col1, col2,...) VALUES (val1, val2,...)'.";
	case "02-013":
		return "Make sure the columns you are inserting data into are enclosed in parentheses: 'INSERT INTO table (col1, col2,...) VALUES (val1, val2,...)'.";
	case "02-014":
		return "Check that your query has all the columns and their values that you need to insert. Check spelling and make sure the order of items in your query matches the order in the prompt.";
	case "02-015":
		return "Make sure you are only listing columns you need to put data into and that the order of items in your query matches the order listed in the prompt.";
	case "02-016":
		return "Make sure you are inserting the correct values into columns. Check spelling and that the order of columns and values are the same: '(colX, colY, colZ) VALUES (valX, valY, valZ);'.";
	case "02-017":
		return "If you are inserting data into every column of a table, you don't need to list all the columns in your query. Simply leave the columns out and insert data in the same order the columns are listed in the table ('INSERT INTO table VALUES(val1, val2,...)').";
	case "02-018":
		return "Make sure you are setting the columns that are listed in the prompt.";
	case "02-019":
		return "Double check you are setting the columns to their correct values as listed in the prompt.";
	case "02-020":
		return "It looks like you are setting the value of a column twice. Try to avoid doing that.";
	case "02-021":
		return "The structure of an UPDATE query is: 'UPDATE <table> SET <col1> = <val1>, <col2> = <val2>, ... WHERE <condition>'. Make sure you are following the <col1> = <val1> part.";
	case "02-022":
		return "Make sure you list only the columns you are inserting data into and that each column has a corresponding value: '... (col1, col2,...) VALUES (val1, val2,...);'.";
	case "02-023":
		return "Make sure both the columns and values are enclosed in parentheses: 'INSERT INTO table (col1, col2,...) VALUES (val1, val2,...)'.";

    # BLOCK 3: Tables, JOIN, ON
    case "03-001":
		return "Aw snap! Make sure you joined all the tables you are calling columns from.";
    case "03-002":
		return "Easy, there! Try to join each table only once. Double check you didn't join a table multiple times.";
    case "03-003":
		return "Try to join only the tables you are requesting columns from.";
    case "03-004":
		return "Double check your JOIN statements. They should follow: 'JOIN table1 ON table1.column = table2.column'.";
    case "03-005":
		return "Make sure the condition of your ON statement makes sense; table1.column and table2.column should link the two tables together by sharing a piece of data.";
    case "03-006":
		return "Double check that one of your ON condition columns comes from the table you are joining (i.e. in the example 'JOIN cities ON countries.code = parks.name' neither countries.code nor parks.name is from the table cities).";
    case "03-007":
		return "Whoops! It looks like you are using column in an 'ON' condition more than once. This probably shouldn't be the case.";
    case "03-008":
		return "FROM and JOIN statements should be followed by a table name. Check if instead you have a 'table.column' and change it to just a 'table'.";
	case "03-009":
		return "It looks there's a column that should be in an ON condition that you are missing. Double check your ON statements.";

    # BLOCK 4: WHERE, AND
    case "04-001":
		return "Make sure your WHERE meets all the criteria you need. You should have to use an 'AND'.";
    case "04-002":
		return "Whoops! You only need an 'AND' when using a 'WHERE' and you need to meet two criteria (i.e. WHERE <column1> = <value1> AND <column2> >= <value2>).";
    case "04-003":
		return "Make sure you are only affecting the rows you need to be. Think about using a 'WHERE' statement.";
    case "04-004":
		return "If you want rows that meet multiple conditions, try using 'AND' instead of mulitple 'WHERE' statements.";
    case "04-005":
		return "It looks like you're using a 'WHERE' statement. 'WHERE' is needed when you only want the rows that meet a specific condition.";
    case "04-006":
		return "Double check your 'WHERE' statement matches the structure 'WHERE table.column >= condition' (e.g. WHERE nutrition.calories >= 3000).";
    case "04-007":
		return "Make sure you're using the correct column in your 'WHERE' statement.";
    case "04-008":
		return "Confirm the logic of your 'WHERE' statement is what you need. Check the relationship (<, >, <=, >=, =, LIKE) and the condition (3000, '%K', 'pancakes').";
    case "04-009":
		return "Make sure your WHERE meets all the criteria you need. You should have to use an 'OR'.";
    case "04-010":
		return "Whoops! You only need an 'OR' when using a 'WHERE' and you need to meet at least one criteria (i.e. WHERE <column1> = <value1> OR <column2> >= <value2>).";
    case "04-011":
		return "If you need to sort the results of your query, try adding the 'ORDER BY' statement.";
    case "04-012":
		return "It looks like you have more than one 'ORDER BY' statement. If you need to sort by multiple columns, try using the structure 'ORDER BY <column1> ASC, <column2> DESC'";
    case "04-013":
		return "Try to use the structure 'ORDER BY <column1> ASC, <column2> DESC'";
    case "04-014":
		return "In your 'ORDER BY' condition, make sure you are sorting the correct column.";
    case "04-015":
		return "In your 'ORDER BY' condition, double check that you are sorting the results in the correct order (ASC or DESC).";

	# BLOCK 5: Commas
	case "05-001":
		return "Your final query should not require any commas.";
	case "05-002":
		return "It looks like you have a comma where you don't need one.";
	case "05-003":
		return "It looks like you are missing a comma.";
	case "05-004":
		return "Double check that all of your parentheses are closed.";
  }
}
