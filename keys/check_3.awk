#
# Loden Henning
# GROK Lab 2018
#
# This script checks the free response answers of quiz 3 for common mistakes.
#

@include "checker_v1.6.awk"

BEGIN {
	# Answers from key:

	# Defines the command of the query.
	# Commands are: SELECT ... FROM, SHOW, USE, INSERT, UPDATE, DELETE, CREATE as "select", "show", "use", "insert", "update", "delete", "create" respectively.
	# Currently supports "select".
	# The command is placed in index [0]. This should never be null.
	command[0] = "insert";
	# Indexes [1] and onward are supplemental.
    # For SELECT , [1] may be "distinct".
    # For SHOW, [1] must be either "databases" or "tables".
    # For USE, [1] must be the name of a database.
	# For INSERT, [1] must be the name of a table.
	# For UPDATE, [1] must be the name of a table.
	# For DELETE, [1] must be the name of a table.
	# For CREATE, [1] must be either "database" or "table". [2] must be the name of the database or table.
	command[1] = "Penguins";

	# Defines array containing all required columns to select (e.g. SELECT <...>, <...> FROM).
	# Do not include columns for ON statements (e.g. ON <...> = <...>).
	SELECT_cols[0] = null;

	# Defines array containing all required tables to join (e.g. FROM <table0> JOIN <table1> ... JOIN <table2>).
	FROM_tables[0] = null;

	# Defines array containing all columns that need be used in ON statements (e.g. ON <table1.column> = <table2.column>).
	# The columns are paired such that elements [0] and [1] have to be used together (e.g. ON [0] = [1]), then [2] and [3], etc..
	# If a column is used in two ON statements, repeat the column in this array.
	ON_cols[0] = null;

	# Defines array containing all columns and datatypes needed in CREATE TABLE query (e.g. CREATE TABLE table1 (<col0> <datatype0>, <col1> <datatype1>);).
	# The indexes are paried such that the first element is the column name and the second is the datatype (e.g. [0] is calories and [1] is int).
	# This pattern carries on with [2] & [3] then [4] & [5] etc..
	# These need to be indexed in the order the columns should be in the table.
	CREATE_cols[0] = null;

	# Defines array containing all columns and values needed in UPDATE query (e.g. UPDATE table1 SET col0 = val1, col2 = val3 WHERE ...;).
	# The indexes are paired such that the first element is the column name and the second is the value to be given (e.g. [0] is calories and [1] is 300).
	# This pattern carries on with [2] & [3] then [4] & [5] etc..
	UPDATE_cols[0] = null;

	# Defines two corresponding arrays containing the columns and values needed in INSERT query (e.g. INSERT INTO table1 (col0, col1, col2) VALUES (val0, val1, val2);).
	# The indexes are paried such that INSERT_cols[n] corresponds to INSERT_vals[n].
	# For an INSERT where all columns will be filled and columns don't need to be listed (e.g. INSERT INTO table1 VALUES (val0, val1, val2);), INSERT_cols[0] should be set to *.
	INSERT_cols[0] = "Name";
	INSERT_cols[1] = "Size";
	INSERT_cols[2] = "Weight";

	INSERT_vals[0] = "Chinstrap";
	INSERT_vals[1] = "M";
	INSERT_vals[2] = "5.0";

	# Defines array containing elements of all WHERE conditions (e.g. WHERE <element0> >= <element1> AND <element2> LIKE <element3>).
	# The conditions are grouped such that elements [0], [1], and [2] have to be used together.
	# [0] is the column, [1] is the relationship (e.g. =, >=, LIKE, etc.), and [2] is the condition (e.g. 3000, "%K").
	WHERE_cond[0] = null;

	# Defines array containing information about an ORDER BY statement.
	# Array elements are paired with the first being the column and the second being the sort (0 == ASC, 1 == DESC) (e.g. [0] is countries.code and [1] is 1).
	ORDERBY_cond[0] = null;

	# Defines variables with amounts of each statement in key (e.g. "SELECT...FROM...WHERE...AND...;" has 1 WHERE, 1 AND, 0 OR).
	num_JOIN_req = 0;
	num_WHERE_req = 0;
	num_AND_req = 0;
	num_OR_req = 0;
}

{checker(command, SELECT_cols, FROM_tables, ON_cols, CREATE_cols, UPDATE_cols, INSERT_cols, INSERT_vals, WHERE_cond, ORDERBY_cond, num_JOIN_req, num_WHERE_req, num_AND_req, num_OR_req);}

END {}
