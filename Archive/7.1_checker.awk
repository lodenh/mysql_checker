#
# Loden Henning
# GROK Lab 2018
#
# This script checks the free response answers of quiz 7.1 for common mistakes.
#

BEGIN {
  # Ignores letter cases (e.g. A == a is true)
  IGNORECASE = 1;

  # Sets field separators to:
  # 1) [space] then [=] then [space]
  # 2) [=]
  # 3) [space]
  # 4) [space] then [=]
  # 5) [=] then [space]
  # 6) [,] then [space]
  FS = "( = )|(=)|( )|( =)|(= )|(, )";

  # Answers from key:

  # Defines array containing all required columns to select (e.g. SELECT <...> <...> FROM).
  # Do not include columns for ON statements (e.g. ON <...> = <...>).
  columns_req[0] = "food.name";
  columns_req[1] = "food.country";
  columns_req[2] = "restaurants.restaurant";
  columns_req[3] = "nutrition.calories";

  # Defines array containing all required tables to join (e.g. FROM <...> JOIN <...> ... JOIN <...>)
  tables_req[0] = "restaurants";
  tables_req[1] = "nutrition";
  tables_req[2] = "food";

  # Defines variables with amounts of each statement in key (e.g. "SELECT ... FROM ...;" has 1 SELECT, 1 FROM, 0 AND)
  num_SELECT_req = 1;
  num_FROM_req = 1;
  num_AND_req = 0;

}

{print "\n\n---------------LINE " NR "---------------"}


#-----------------------------------------------------------------------------------------------------------------
# Checks if anything was submitted.
#

!($0 ~ ".") {print "Did not attempt"}


#-----------------------------------------------------------------------------------------------------------------
# Checks if line has required number of SELECT statements. Creates variable fld_SELECT for field of last SELECT (default value is 0).
#

SELECTs_detected = 0;
fld_SELECT = 0;
{for (n = 1; n <= NF; n++){
  {if ($n == "select"){
    fld_SELECT = n;
    SELECTs_detected = SELECTs_detected + 1;}
  else{}}
}}
{if (SELECTs_detected < num_SELECT_req){print "Missing SELECT"}}
{if (SELECTs_detected > num_SELECT_req){print "Unnecessary SELECT"}}


#-----------------------------------------------------------------------------------------------------------------
# Checks if line has required number of FROM statements. Sets variable fld_FROM field of last FROM (default value is 0).
#

FROMs_detected = 0;
fld_FROM = 0;
{for (n = 1; n <= NF; n++){
  {if ($n == "from"){
    fld_FROM = n;
    FROMs_detected = FROMs_detected + 1;}
  else{}}
}}
{if (FROMs_detected < num_FROM_req){print "Missing FROM"}}
{if (FROMs_detected > num_FROM_req){print "Unnecessary FROM"}}


#-----------------------------------------------------------------------------------------------------------------
# Tests if all required columns are requested. Detects duplicates.
#

# Note: This doesn't work correctly when the user input has no FROM (default fld_FROM = 0)

{delete columns_detected;}
array_end = 0;
# Tests all field between SELECT and FROM
{for (n = (fld_SELECT + 1); n < fld_FROM; n++){
  column_found = 0;
  duplicate_found = 0;
  # Tests if $n matches a required column
  {for (i in columns_req){
    {if ($n ~ columns_req[i]){
      column_found = 1;
      # Tests if the column found ($n) has already been detected on this line
      {for (g in columns_detected){
        # columns_detected contains columns that are required and have been found in the user's input
        {if ($n ~ columns_detected[g]){
          duplicate_found = 1;
          print "Column " $n " was joined multiple times";}
        # If $n was not a duplicate, it is added to the end of the columns_detected array
        else {}}
      }}
      # If $n was not a duplicate, it is added to the end of the columns_detected array
      {if (duplicate_found == 0){
        columns_detected[array_end] = $n;
        array_end = array_end + 1;}
      else {}}
    }}
  }}
  # Prints error if the field tested is not a required column and contains a period.
  # Testing if a column contains a period may cause issues later depending on how "." as an FS is handled.
  {if ((column_found == 0) && ($n ~ /\./)) {print "Unnecessary column: " $n}}
}}

# Checks if all required columns were detected
{for (n in columns_req) {
  column_found = 0;
  {for (i in columns_detected) {
    {if (columns_detected[i] ~ columns_req[n]) {column_found = 1}
    else {}}
  }}
  {if (column_found == 0) {print "Missing column:\t" columns_req[n]}}
}}

# Clean up
{delete columns_detected;}


#-----------------------------------------------------------------------------------------------------------------
# Tests if all tables are joined. Detects duplicates. Checks if JOIN table matches ON condition.
#

array_end = 0;
# This goes through every field of a line.
{for (n = 1; n <= NF; n++){
  table_found = 0;
  duplicate_found = 0;
  # When the field is FROM or JOIN, the following field (called $x) is tested.
  {if ($n == "from" || $n == "join"){
    x = n + 1;
    # Tests if $x matches a required table
    {for (i in tables_req){
      {if ($x ~ tables_req[i]){
        table_found = 1;
        # Tests if the table found ($x) has already been detected on this line
        {for (g in tables_detected){
          # tables_detected contains tables that are required and have been found in the user's input
          {if ($x ~ tables_detected[g]){
            duplicate_found = 1;
            print "Table " $x " was joined multiple times";}
          else {}}
        }}
        # If $x was not a duplicate, it is added to the end of the tables_detected array
        {if (duplicate_found == 0){
          tables_detected[array_end] = $x;
          array_end = array_end + 1;}
        else {}}
      }}
    }}
    # If $x does not match a required table, a message is displayed
    {if (table_found == 0){print "Field " x " (" $x ") is not a required table."}}
  }}
}}

# Checks if all required tables were detected
{for (n in tables_req) {
  table_found = 0;
  {for (i in tables_detected) {
    {if (tables_req[n] ~ tables_detected[i]) {table_found = 1}
    else {}}
  }}
  {if (table_found == 0) {print "Missing table:\t" tables_req[n]}}
}}

# Checks if JOIN table matches ON condition
{for (n = 1; n <= NF; n++){
  # Prepare flag variables
  match1_1 = 0;
  match1_2 = 0;
  match2 = 0;
  error_printed = 0;
  {if ($n == "on"){
#    print "$(n + 1) = " $(n + 1) "\t$(n + 2) = " $(n + 2) "\n";
    # Tests if exactly one ON condition column matches table before ON statement
    {if ($(n + 1) ~ $(n - 1)){match1_1 = 1}}
    {if ($(n + 2) ~ $(n - 1)){match1_2 = 1}}
    {if ( (match1_1 == 0) && (match1_2 == 0) ){
      print "Neither ON condition column matches table preceeding ON (" $(n - 1) ")";
      error_printed =1}}
    {if ( (match1_1 == 1) && (match1_2 == 1) ){
      print "Both ON condition columns are from table " $(n - 1)}}
    # Tests if either ON condition column matches any other detected table that is not the one before ON statement
    {for (i in tables_detected){
      {if ( ($(n + 1) ~ tables_detected[i]) || ($(n + 2) ~ tables_detected[i]) ){
        match2 = 1;
#        print "\t-1: " $(n - 1);
#        print "\t+1: " $(n + 1);
#        print "\t+2: " $(n + 2);
#        print "\tt_d:" tables_detected[i];
        {if ($(n - 1) ~ tables_detected[i]){}
        else if ( ($(n + 1) == $(n + 2)) && (error_printed == 0)){print "Both ON condition columns are from table " tables_detected[i]}
        else if ($(n + 1) != $(n + 2)){}
        else {}}
      }}
    }}
##    {if (match2 == 0){print "ON condition column does not match any tables starting in field " n}}
  }}
}}

# Clean up
{delete tables_detected;}


#-----------------------------------------------------------------------------------------------------------------
# Checks if line has required number of AND statements.
#

ANDs_detected = 0;
{for (n = 1; n <= NF; n++){
  {if ($n == "and"){ANDs_detected = ANDs_detected + 1}
  else{}}
}}
{if (ANDs_detected < num_AND_req){print "Missing AND"}}
{if (ANDs_detected > num_AND_req){print "Unnecessary AND"}}


#-----------------------------------------------------------------------------------------------------------------
# Checks for semicolon at end of the line
#

# This no longer works for some reason
#{if ($0 !~ /;$/) {print "Missing semicolon at end"}}


END {}
