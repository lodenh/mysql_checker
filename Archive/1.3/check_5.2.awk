#
# Loden Henning
# GROK Lab 2018
#
# This script checks the free response answers of quiz 5.2 for common mistakes.
#

@include "checker_v1.3"

BEGIN {
  # Answers from key:

  # Defines array containing all required columns to select (e.g. SELECT <...>, <...> FROM).
  # Do not include columns for ON statements (e.g. ON <...> = <...>).
  columns_req[0] = "parks.name";
  columns_req[1] = "countries.country";
  columns_req[2] = "countries.population";

  # Defines array containing all required tables to join (e.g. FROM <...> JOIN <...> ... JOIN <...>)
  tables_req[0] = "countries";
  tables_req[1] = "parks";

  # Defines array containing all columns that need be used in ON statements (e.g. ON <table1.column> = <table2.column>).
  # The columns are paired such that elements [0] and [1] have to be used together (e.g. ON [0] = [1]), then [2] and [3], etc..
  # If a column is used in two ON statements, repeat the column in this array.
  on_col[0] = "parks.countrycode";
  on_col[1] = "countries.code";

  # Defines array containing elements of all WHERE conditions (e.g. WHERE <element0> >= <element1> AND <element2> LIKE <element3>).
  # The conditions are grouped such that elements [0], [1], and [2] have to be used together.
  # [0] is the column, [1] is the relationship (e.g. =, >=, LIKE, etc.), and [2] is the condition (e.g. 3000, "%K").
  where_cond[0] = null;

  # Defines array containing information about an ORDER BY statement.
  # Array elements are paired with the first being the column and the second being the sort (0 == ASC, 1 == DESC) (e.g. [0] is countries.code and [1] is 1).
  order_by[0] = null;

  # Defines variables with amounts of each statement in key (e.g. "SELECT ... FROM ...;" has 1 SELECT, 1 FROM, 0 AND).
  num_SELECT_req = 1;
  num_FROM_req = 1;
  num_JOIN_req = 1;
  num_WHERE_req = 0;
  num_AND_req = 0;
  num_OR_req = 0;
}

{print "\n\n---------------LINE " NR "---------------"}

{checker(num_SELECT_req, num_FROM_req, num_JOIN_req, num_WHERE_req, num_AND_req, num_OR_req, columns_req, tables_req, on_col, where_cond, order_by);}

END {}
