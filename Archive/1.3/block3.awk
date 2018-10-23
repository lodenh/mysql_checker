#
# Loden Henning
# GROK Lab 2018
#
# Checks if all tables are joined, if ON condition matches JOIN table, and JOIN structure.
#

function b3_tableJoined(debug_mode, result_b3, tables_req, on_col){

  #-----------------------------------------------------------------------------------------------------------------
  # Tests if all tables are joined. Detects duplicates.
  #
  array_end = 0;
  # Errors that can be made:
  table_missing = 0;
  table_duplicate = 0;
  table_unnecessary = 0;
  is_column = 0;

  # This goes through every field of a line.
  {for (n = 1; n <= NF; n++){
    table_found = 0;
    duplicate_found = 0;
    # When the field is FROM or JOIN, the following field (field x) is tested.
    {if ($n == "from" || $n == "join"){
      x = n + 1;
      # Tests if field x contains a '.' because a common mistake is a 'table.column' following FROM or JOIN
      {if ($x ~ /\./){
        {if (debug_mode == 1){print "\tis_column: " $x;}}
        is_column = 1;
        }
      else {
        # If there is no '.', tests if $x matches a required table
        {for (i in tables_req){
          {if ($x ~ tables_req[i]){
            table_found = 1;
            # Tests if the table found ($x) has already been detected on this line
            {for (g in tables_detected){
              # tables_detected contains tables that are required and have been found in the user's input
              {if ($x ~ tables_detected[g]){
                {if (debug_mode == 1){print "\ttable_duplicate: " tables_detected[g];}}
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
      }}
      # If $x does not match a required table, a message is displayed
      {if (table_found == 0){
        {if (debug_mode == 1){print "\ttable_unnecessary: " $x;}}
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
      {if (debug_mode == 1){print "\ttable_missing: " tables_req[n];}}
      table_missing = 1;
      result_b3[0]++;
    }}
  }}

  # Print tips
  {if (is_column > 0){
    print tip("03-008");
  } else{
    {if (table_missing > 0){
      print tip("03-001");
    }}
    {if (table_duplicate > 0){
      print tip("03-002");
    }}
    {if (table_unnecessary > 0){
      print tip("03-003");
    }}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # Checks if JOIN table matches ON condition. Checks ON condition columns are correctly paired.

  # Used when creating array with location of all ON statements.
  array_end = 0;
  # Errors that can be made:
  ON_bad_columns = 0;       # 2 bad columns
  ON_bad_pair = 0;          # 1 bad column
  ON_duplicate_col = 0;
  ON_bad_table = 0;
  JOIN_bad_structure = 0;

  # TODO::
  #  JOIN bad structure

  {for (i in fld_ON){delete fld_ON[i]}}

  {for (n = 1; n <= NF; n++){
    {if ($n == "on"){
      fld_ON[array_end] = n;
      array_end = array_end + 1;
    }}
  }}


  {for (y in fld_ON){
    n = fld_ON[y] + 1;

    # Tests if the field after ON contains an '='. If so, we assume structure 'ON table1.col1=table2.col2'.
    {if ($n ~ "="){

      col_was_found = 0;
      found_on_col_1 = null;
      found_on_col_2 = null;

      {for (i in on_col){
        already_detected= 0;
        {if ($n ~ on_col[i]){

          {for (g in columns_detected){
            {if (on_col[i] == columns_detected[g]){
              already_detected = 1;
              ON_duplicate_col = 1;
              {if (debug_mode == 1){print "\tON_duplicate_col: " on_col[i];}}
              result_b3[0]++;
            }}
          }}

          {if (already_detected == 0){
            columns_detected[array_end] = on_col[i];
            array_end++;
            col_was_found = 1;
            {if (found_on_col_1 != null){found_on_col_2 = i}}
            {if (found_on_col_1 == null){found_on_col_1 = i}}
          }}
        }}
      }}

      {if (col_was_found == 1){

        # If found_on_col_2 is not set, we know only one required column was found, thus ON_bad_pair.
        {if (found_on_col_2 == null){
          ON_bad_pair = 1;
          {if (debug_mode == 1){print "\tON_bad_pair"}}
          result_b3[0]++;
        }}

        # If col_was_found == 0, we know no required column were found, thus ON_bad_columns.
      } else{
        ON_bad_columns = 1;
        {if (debug_mode == 1){print "\tON_bad_columns"}}
        result_b3[0]++;
      }}

      # Test if one column of the ON condition is from the table being joined
      {if ($n !~ $(n-2)){

        ON_bad_table = 1;
        {if (debug_mode == 1){print "\tON_bad_table"}}
        result_b3[0]++;
      }}

      # Test for a structure of 'JOIN table ON table.col=table.col'.
      {if ($(n-3) != "join" || $(n-2) ~ /\./ || $(n-1) != "on" || $n !~ /.*\..*=.*\..*/){
        JOIN_bad_structure = 1;
        {if (debug_mode == 1){print "\tJOIN_bad_structure"}}
        result_b3[0]++;
      }}

    # Field after ON does not contain '='. Assume structure 'ON table1.col1 = table2.col2'.
    } else {

        col_was_found = 0;
        found_on_col_1 = null;
        found_on_col_2 = null;

        {for (i in on_col){
          already_detected= 0;
          {if ($n ~ on_col[i] || $(n+2) ~ on_col[i]){

            {for (g in columns_detected){
              {if (on_col[i] == columns_detected[g]){
                already_detected = 1;
                ON_duplicate_col = 1;
                {if (debug_mode == 1){print "\tON_duplicate_col: " on_col[i];}}
                result_b3[0]++;
              }}
            }}

            {if (already_detected == 0){
              columns_detected[array_end] = on_col[i];
              array_end++;
              col_was_found = 1;
              {if (found_on_col_1 == null){found_on_col_1 = i}}
              {if (found_on_col_1 != null){found_on_col_2 = i}}
            }}
          }}
        }}

        {if (col_was_found == 1){

          # If found_on_col_2 is not set, we know only one required column was found.
          {if (found_on_col_2 == null){
            # We test if $n == $(n+2) to see if they did 'ON table1.col1 = table1.col1'.
            {if ($n == $(n+2)){
              ON_duplicate_col = 1;
              {if (debug_mode == 1){print "\tON_duplicate_col: " $n;}}
              result_b3[0]++;
            } else {
              ON_bad_pair = 1;
              {if (debug_mode == 1){print "\tON_bad_pair"}}
              result_b3[0]++;
            }}
          }}

          # If col_was_found == 0, we know no required column were found, thus ON_bad_columns.
        } else{
          ON_bad_columns = 1;
          {if (debug_mode == 1){print "\tON_bad_columns"}}
          result_b3[0]++;
        }}

        # Test if one column of the ON condition is from the table being joined
        table_found_1 = 0;
        table_found_2 = 0;
        {if ($n ~ $(n-2)){table_found_1 = 1}}
        {if ($(n+2) ~ $(n-2)){table_found_2 = 1}}
        {if (table_found_1 + table_found_2 != 1){
          ON_bad_table = 1;
          {if (debug_mode == 1){print "\tON_bad_table"}}
          result_b3[0]++;
        }}

        # Test for a structure of 'JOIN table ON table.col = table.col'.
        {if ($(n-3) != "join" || $(n-2) ~ /\./ || $(n-1) != "on" || $n !~ /\./ || $(n+1) != "=" || $(n+2) !~ /\./){
          JOIN_bad_structure = 1;
          {if (debug_mode == 1){print "\tJOIN_bad_structure"}}
          result_b3[0]++;
        }}

    }}
  }}

  # Print tips
  {if (JOIN_bad_structure > 0){
    print tip("03-004");
  } else {
    {if (ON_bad_columns > 0){
      print tip("03-005");
    }}
    {if (ON_bad_pair > 0){
      print tip("03-005");
    }}
    {if (ON_duplicate_col > 0){
      print tip("03-007");
    }}
    {if (ON_bad_table > 0){
      print tip("03-006");
    }}
  }}

} # End of Function
