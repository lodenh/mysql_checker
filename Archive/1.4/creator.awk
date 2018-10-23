#
#   Loden Henning
#   GROK Lab 2018
#

# Assumptions Made:
# 1) Input entered into creator.awk is correct answer
# 2) There is only one SELECT statement
# 3) There is only one FROM statement

BEGIN {IGNORECASE = 1; print ""}


# Tests if the input has a SELECT statement and sets the variable "fld_select" to field number of SELECT.

{if ($0 ~ /SELECT/) {
  for(n = 1; n <= NF; n++) {
    {if ($n ~ /SELECT/) {fld_select = n; print "SELECT was found in field " fld_select}}
  }}
else {print "SELECT was not found"}
}


# Tests if the input has a FROM statement and sets the variable "fld_from" to field number of FROM.

{if ($0 ~ /FROM/) {
  for(n = 1; n <= NF; n++) {
    {if ($n ~ /FROM/) {fld_from = n; print "FROM was found in field " fld_from}}
  }}
else {print "FROM was not found"}
}


# Creates the array "columns_req" containing all the columns the user wishes to display.
# It works by mapping all the fields between SELECT and FROM in the input to the array "columns_req" starting with element 0.

# Note: All but the last column have commas at the end. This may need to be addressed later.

{num_columns = fld_from - fld_select - 1}

{for (n = 0; n < num_columns; n++) {
  columns_req[n] = $(n + fld_select + 1);
  print "columns_req[" n "] = " columns_req[n];
}}


END {}
