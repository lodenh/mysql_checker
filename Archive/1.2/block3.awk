#
# Loden Henning
# GROK Lab 2018
#
# Checks if all tables are joined, if ON condition matches JOIN table, and JOIN structure.
#

@include "functions.awk"
@include "tips.awk"

function b3_tableJoined(debug_mode, result_b3, tables_req, on_col){

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
