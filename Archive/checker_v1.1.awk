#
# Loden Henning
# GROK Lab 2018
#
# This function checks students' free response answers for common mistakes.
#

@include "functions.awk"
@include "tips.awk"

#####################################################################################################################################################
function b1_select_from(result_b1, num_SELECT_req, num_FROM_req, tables_req, tables_detected){

  #-----------------------------------------------------------------------------------------------------------------
  # Checks if line has required number of SELECT statements. Creates variable fld_SELECT for field of last SELECT (default value is 0).
  #
  SELECTs_detected = 0;
  fld_SELECT = 0;
  # Errors that can be made:
  SELECT_misplaced = 0;
  SELECT_missing = 0;
  SELECT_extra = 0;

  {for (n = 1; n <= NF; n++){
    {if ($n == "select"){
      fld_SELECT = n;
      SELECTs_detected = SELECTs_detected + 1;}
    else{}}
  }}
  {if (SELECTs_detected < num_SELECT_req){
    {if (debug_mode == 1){print "SELECT_missing";}}
    SELECT_missing = 1;
    result_b1[0]++;
  }}
  {if (SELECTs_detected > num_SELECT_req){
    {if (debug_mode == 1){print "SELECT_extra";}}
    SELECT_extra = 1;
    result_b1[0]++;
  }}
  {if (fld_SELECT != 1 && SELECT_missing == 0){
    {if (debug_mode == 1){print "SELECT_misplaced";}}
    SELECT_misplaced = 1;
    result_b1[0]++;
  }}

  # Print tips
  {if (SELECT_misplaced > 0 || SELECT_missing > 0 || SELECT_extra > 0){
    print tip("01-001");
  }}


  #-----------------------------------------------------------------------------------------------------------------
  # Checks if line has required number of FROM statements. Sets variable fld_FROM field of last FROM (or first field != SELECT or table.column).
  #
  FROMs_detected = 0;
  fld_FROM = 0;
  # Errors that can be made:
  FROM_missing = 0;
  FROM_extra = 0;
  FROM_no_table = 0;

  {for (n = 1; n <= NF; n++){
    {if ($n == "from"){
      fld_FROM = n;
      FROMs_detected = FROMs_detected + 1;}
    else{}}
  }}
  # If FROM is not found, fld_FROM is set to first field that is not SELECT or field containing "." (table.column)
  {if (fld_FROM == 0){
    {for (n = 1; n <= NF; n++){
## Testing if a column contains a period may cause issues later depending on how "." as an FS is handled.
      {if ($n != "SELECT" && $n !~ /\./){
        fld_FROM = n;
        break;}}
    }}
  }}

  {if (FROMs_detected < num_FROM_req){
    {if (debug_mode == 1){print "FROM_missing";}}
    FROM_missing = 1;
    result_b1[0]++;
  }}
  {if (FROMs_detected > num_FROM_req){
    {if (debug_mode == 1){print "FROM_extra";}}
    FROM_extra = 1;
    result_b1[0]++;
  }}

  # Checks if the field after FROM is a required table.
  table_found = 0;
  {if (FROM_missing == 0){
    {for (i in tables_req){
      {if ($(fld_FROM + 1) ~ tables_req[i]){table_found = 1}}
    }}
    {if (table_found == 0){
      {if (debug_mode == 1){print "FROM_no_table: " $(fld_FROM + 1);}}
      FROM_no_table = 1;
      result_b1[0]++;
    }}
  }}

  # Print tips
  {if (FROM_missing > 0 || FROM_extra > 0){
    print tip("01-002");
  }}
  {if (FROM_no_table > 0){
    print tip("01-003");
  }}
  {if (FROM_no_table > 0 AND (FROM_missing > 0 || FROM_extra > 0)){
    print tip("01-004");
  }}

  # Package variables for return
  {result_b1[2] = fld_SELECT;}
  {result_b1[3] = fld_FROM;}

}

#####################################################################################################################################################
function b2_requestedColumns(result_b2, fld_SELECT, fld_FROM, columns_req, num_JOIN_req){

  #-----------------------------------------------------------------------------------------------------------------
  # Tests if all required columns are requested. Detects duplicates.
  # Note: This doesn't work correctly when the user input has no FROM (default fld_FROM = 0)
  #
  {delete columns_detected;}
  array_end = 0;
  # Errors that can be made:
  col_missing = 0;
  col_unnecessary = 0;
  col_duplicate = 0;
  not_col = 0;

  # Tests all field between SELECT and FROM
  {for (n = (fld_SELECT + 1); n < fld_FROM; n++){
    column_found = 0;
    duplicate_found = 0;
    not_col_temp = 0;
    # Tests if $n has a period signifying it's a table.column
    {if (num_JOIN_req != 0){
      {if ($n !~ /\./){
        {if (debug_mode == 1){print "not_col: " $n;}}
        not_col = 1;
        not_col_temp = 1;
        result_b2[0]++;
      }}
    }}
    # Tests if $n matches a required column
    {if (not_col_temp == 0){
      {for (i in columns_req){
#        print $n " vs " columns_req[i];
        {if ($n ~ columns_req[i]){
#          print "TRUE ^";
          column_found = 1;
          # Tests if the column found ($n) has already been detected on this line
          {for (g in columns_detected){
            # columns_detected contains columns that are required and have been found in the user's input
            {if ($n ~ columns_detected[g]){
              {if (debug_mode == 1){print "col_duplicate: " $n;}}
              duplicate_found = 1;
              col_duplicate = 1;
              result_b2[0]++;
            }}
          }}
          # If $n was not a duplicate, it is added to the end of the columns_detected array
          {if (duplicate_found == 0){
            columns_detected[array_end] = $n;
            array_end = array_end + 1;}
          else {}}
        } else{
#          print "FALSE ^";
        }}
      }}
    }}
    # Prints error if the field tested is not a required column and contains a period.
## Testing if a column contains a period may cause issues later depending on how "." as an FS is handled.
    {if ((column_found == 0) && ($n ~ /\./)) {
      {if (debug_mode == 1){print "col_unnecessary: " $n;}}
      col_unnecessary = 1;
      result_b2[0]++;
    }}
  }}

  # Checks if all required columns were detected
  {for (n in columns_req) {
    column_found = 0;
    {for (i in columns_detected) {
      {if (columns_detected[i] ~ columns_req[n]){column_found = 1}
      else {}}
    }}
    {if (column_found == 0){
      {if (debug_mode == 1){print "col_missing: " columns_req[n];}}
      col_missing = 1;
      result_b2[0]++;
    }}
  }}

  # Print tips
  {if (col_missing > 0){
    print tip("02-001");
  }}
  {if (col_unnecessary > 0){
    print tip("02-002");
  }}
  {if (col_duplicate > 0){
    print tip("02-003");
  }}
  {if (not_col > 0){
    print tip("02-004");
  }}

}


#####################################################################################################################################################
function b3_tableJoined(result_b3, tables_req, on_col){

  #-----------------------------------------------------------------------------------------------------------------
  # Tests if all tables are joined. Detects duplicates.
  #
  array_end = 0;
  # Errors that can be made:
  table_missing = 0;
  table_duplicate = 0;
  table_unnecessary = 0;

  # This goes through every field of a line.
  {for (n = 1; n <= NF; n++){
    table_found = 0;
    duplicate_found = 0;
    # When the field is FROM or JOIN, the following field (called field $x) is tested.
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
              {if (debug_mode == 1){print "table_duplicate: " tables_detected[g];}}
              duplicate_found = 1;
              table_duplicate = 1;
              result_b3[0]++;
            }
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
      {if (table_found == 0){
        {if (debug_mode == 1){print "table_unnecessary: " $x;}}
        table_unnecessary = 1;
        result_b3[0]++;
      }}
    }}
  }}

  # Checks if all required tables were detected
  {for (n in tables_req) {
    table_found = 0;
    {for (i in tables_detected) {
      {if (tables_req[n] ~ tables_detected[i]) {table_found = 1}
      else {}}
    }}
    {if (table_found == 0) {
      {if (debug_mode == 1){print "table_missing: " tables_req[n];}}
      table_missing = 1;
      result_b3[0]++;
    }}
  }}

  # Print tips
  {if (table_missing > 0){
    print tip("03-001");
  }}
  {if (table_duplicate > 0){
    print tip("03-002");
  }}
  {if (table_unnecessary > 0){
    print tip("03-003");
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # Checks structure of JOIN, ON statements. Checks if JOIN table matches ON condition. Checks ON condition columns are correct.

  # Creates array with location of all JOIN statements
  array_end = 0;
  # Errors that can be made:
  JOIN_bad_structure = 0;

  {for (n = 1; n <= NF; n++){
    {if ($n ~ "join"){
      fld_JOIN[array_end] = n;
      array_end = array_end + 1;
    }}
  }}

  # Checks structure of JOIN, ON statements (JOIN <table> ON <col1> <col2>)
  # Note: Currently, "=" can not be checked for because they act as a field separator
  error = 0;
  {for (i in fld_JOIN){
    n = fld_JOIN[i];
    {if ($(n + 1) ~ /\./ || $(n + 2) !~ "ON" || $(n + 3) !~ /\./ || $(n + 4) !~ /\./){
      error = 1;
    }}
  }}
  {if (error == 1){
    {if (debug_mode == 1){print "JOIN_bad_structure";}}
    JOIN_bad_structure = 1;
    result_b3[0]++;
  }}

  # Print tips
  {if (JOIN_bad_structure > 0){
    print tip("03-004");
  }}


  #-----------------------------------------------------------------------------------------------------------------
  # Checks if JOIN table matches ON condition. Checks ON condition columns are correctly paired.

  # Creates array with location of all ON statements.
  array_end = 0;
  # Errors that can be made:
  ON_bad_pair = 0;
  ON_bad_table = 0;

  {for (n = 1; n <= NF; n++){
    {if ($n ~ "on"){
      fld_ON[array_end] = n;
      array_end = array_end + 1;
    }}
  }}

  # Checks if ON condition columns are correctly paired ("countries.code = restaurants.countrycode" not "countries.code = food.name")
  {length_on_col = last_element(on_col);}
  {length_fld_ON = last_element(fld_ON);}

  {for (i = 0; i <= length_on_col; i += 2){
    {req_col1 = 0}
    {req_col2 = 0}
    {for (x = 0; x <= length_fld_ON; x++){
      n = fld_ON[x];
      # Checks the two fields after ON for on_col[i]. If either are on_col[i], req_col1 is set to true.
      {if ($(n + 1) == on_col[i] || $(n + 1) == on_col[i]";"){req_col1 = 1}}
      {if ($(n + 2) == on_col[i] || $(n + 2) == on_col[i]";"){req_col1 = 1}}
      # Checks the two fields after ON for on_col[i + 1]. If either are on_col[i + 1], req_col2 is set to true.
      {if ($(n + 1) == on_col[i + 1] || $(n + 1) == on_col[i + 1]";"){req_col2 = 1}}
      {if ($(n + 2) == on_col[i + 1] || $(n + 2) == on_col[i + 1]";"){req_col2 = 1}}
    }}
  #  {print "req_col1 = " req_col1 "\t" on_col[i]}
  #  {print "req_col2 = " req_col2 "\t" on_col[i + 1]}
    {if (req_col1 == 0 || req_col2 == 0){
      {if (debug_mode == 1){print "ON_bad_pair: " on_col[i] " = " on_col[i + 1] " should have been an ON condition";}}
      ON_bad_pair = 1;
      result_b3[0]++;
    }}
  }}

  # Checks if JOIN table matches either ON condition
  {for (n = 1; n <= NF; n++){
    # Prepare flag variables
    match1_1 = 0;
    match1_2 = 0;
    match2 = 0;
    {if ($n == "on"){
      # Tests if exactly one ON condition column matches table before ON statement
      {if ($(n + 1) ~ $(n - 1)){match1_1 = 1}}
      {if ($(n + 2) ~ $(n - 1)){match1_2 = 1}}
      {if ( (match1_1 == 0) && (match1_2 == 0) ){
        {if (debug_mode == 1){print "ON_bad_table: Neither condition col matches table " $(n - 1);}}
        ON_bad_table = 1;
        result_b3[0]++;
      }}
      {if ( (match1_1 == 1) && (match1_2 == 1) ){
        {if (debug_mode == 1){print "ON_bad_pair: Both condition cols from table " $(n - 1);}}
        ON_bad_pair = 1;
        result_b3[0]++;
      }}
      # Tests if either ON condition column matches any other detected table that is not the one before ON statement
      {for (i in tables_detected){
        {if ( ($(n + 1) ~ tables_detected[i]) || ($(n + 2) ~ tables_detected[i]) ){
          match2 = 1;
  #        print "\t-1: " $(n - 1);
  #        print "\t+1: " $(n + 1);
  #        print "\t+2: " $(n + 2);
  #        print "\tt_d:" tables_detected[i];
          {if ($(n - 1) ~ tables_detected[i]){}
          else if ( ($(n + 1) == $(n + 2)) && (ON_bad_table == 0)){
            {if (debug_mode == 1){print "ON_bad_pair";}}
            ON_bad_pair = 1;
            result_b3[0]++;
          }
          else if ($(n + 1) != $(n + 2)){}
          else {}}
        }}
      }}
  ##    {if (match2 == 0){print "ON condition column does not match any tables starting in field " n}}
    }}
  }}

  # Print tips
  {if (ON_bad_pair > 0){
    print tip("03-005");
  }}
  {if (ON_bad_table > 0){
    print tip("03-006");
  }}

}

#####################################################################################################################################################
function b4_where(result_b4, num_WHERE_req, num_AND_req){

  #-----------------------------------------------------------------------------------------------------------------
  # Checks if line has required number of WHERE and AND statements and that WHERE conditions match what is required.
  #

  # TODO:: Check WHERE conditions

  WHEREs_detected = 0;
  ANDs_detected = 0;
  # Errors that can be made:
  WHERE_missing = 0;
  WHERE_extra = 0;
  AND_missing = 0;
  AND_extra = 0;

  # Check for WHEREs
  {for (n = 1; n <= NF; n++){
    {if ($n == "where"){WHEREs_detected++}
    else{}}
  }}
  {if (WHEREs_detected < num_WHERE_req){
    {if (debug_mode == 1){print "WHERE_missing";}}
    WHERE_missing = 1;
    result_b4[0]++;
  }}
  {if (WHEREs_detected > num_WHERE_req){
    {if (debug_mode == 1){print "WHERE_extra";}}
    WHERE_extra = 1;
    result_b4[0]++;
  }}

  # Print tips
  {if (WHERE_missing > 0){
    print tip("04-003");
  }}
  {if (WHERE_extra > 0 && num_WHERE_req > 0){
    print tip("04-004");
  }}
  {if (WHERE_extra > 0 && num_WHERE_req == 0){
    print tip("04-005");
  }}

  # Check for ANDs
  {for (n = 1; n <= NF; n++){
    {if ($n == "and"){ANDs_detected++}
    else{}}
  }}
  {if (ANDs_detected < num_AND_req){
    {if (debug_mode == 1){print "AND_missing";}}
    AND_missing = 1;
    result_b4[0]++;
  }}
  {if (ANDs_detected > num_AND_req){
    {if (debug_mode == 1){print "AND_extra";}}
    AND_extra = 1;
    result_b4[0]++;
  }}

  # Print tips
  {if (AND_missing > 0){
    print tip("04-001");
  }}
  {if (AND_extra > 0){
    print tip("04-002");
  }}

}



#####################################################################################################################################################
BEGIN{
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

  debug_mode = 0;
}

function checker(num_SELECT_req, num_FROM_req, num_JOIN_req, num_WHERE_req, num_AND_req, num_OR_req, columns_req, tables_req, on_col, where_cond, order_by){

  # critical_error_made acts as a master flag. If it is set to true, no more block functions are called.
  {critical_error_made = 0}

  #-----------------------------------------------------------------------------------------------------------------
  # Checks if anything was submitted.
  #
  {if ($0 ~ /^$/){
    print "Hmmm... Try to submit something--even if you think you'll be wrong.";
    critical_error_made = 1;
    }}

  # awk does not allow us to pass any variable we wish by reference. Arrays are always passed by reference and nothing else can be.
  # To overcome this, a standard form of array will be used for feedback from block functions.
  # result_block arrays consist of:
  # [0] = A count of the number of errors found in a block. There isn't a need for a count, but it is just as useful as a bool while being more informative.
  # [1] = Currently unused.
  # [2+] = Any variables that were created in the block that need to be used in another block.

  #-----------------------------------------------------------------------------------------------------------------
  # b1_select_from checks for SELECT and FROM and that FROM is followed by a table.
  #
  {if (critical_error_made == 0){
    {result_b1[0] = 0;}
    {b1_select_from(result_b1, num_SELECT_req, num_FROM_req, tables_req, tables_detected);}
    {fld_SELECT = result_b1[2];}
    {fld_FROM = result_b1[3];}
    {if (debug_mode == 1){print "B1 Errors: " result_b1[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # b2_requestedColumns checks for required columns between SELECT and FROM.
  #
  {if (critical_error_made == 0){
    {result_b2[0] = 0;}
    {b2_requestedColumns(result_b2, fld_SELECT, fld_FROM, columns_req, num_JOIN_req);}
    {if (debug_mode == 1){print "B2 Errors: " result_b2[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # b3_tableJoined checks if all tables are joined, if ON condition matches JOIN table, and JOIN structure.
  #
  {if (critical_error_made == 0){
    {result_b3[0] = 0;}
    {b3_tableJoined(result_b3, tables_req, on_col);}
    {if (debug_mode == 1){print "B3 Errors: " result_b3[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # b4_where checks for required number of WHERE and AND statements and that WHERE conditions match what is required.
  #
  {if (critical_error_made == 0){
    {result_b4[0] = 0;}
    {b4_where(result_b4, num_WHERE_req, num_AND_req);}
    {if (debug_mode == 1){print "B4 Errors: " result_b4[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # Checks for semicolon at end of the line
  #
  {if (critical_error_made == 0){
    {if ($0 !~ /;$/){print "Oops! Looks like you're missing a semicolon."}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # Clean up
  #
  {delete columns_detected;}
  {delete tables_detected;}


  # If no errors were detected, print a congratulation
  {if ((result_b1[0] + result_b2[0] + result_b3[0] + result_b4[0]) == 0){print "Nice one!"}}

}
