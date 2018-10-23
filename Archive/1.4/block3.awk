#
# Loden Henning
# GROK Lab 2018
#
# Checks if all tables are joined, JOIN structure, ON condition columns, and if ON condition matches JOIN table.
#

function block3(debug_mode, result_b3, FROM_tables, ON_cols){

  #-----------------------------------------------------------------------------------------------------------------
  # Tests if all tables are joined. Detects duplicates.
  #

	{if (FROM_tables[0] != null){

  array_end = 0;
  # Errors that can be made:
  table_missing = 0;
  table_duplicate = 0;
  table_unnecessary = 0;
  is_column = 0;

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
      } else {
        # If there is no '.', tests if $x matches a required table
        {for (i in FROM_tables){
          {if ($x ~ FROM_tables[i]){
            table_found = 1;
            # Tests if the table found ($x) has already been detected on this line
            {for (g in tables_detected){
              # tables_detected contains tables that are required and have been found in the user's input
              {if ($x ~ tables_detected[g]){
                {if (debug_mode == 1){print "\ttable_duplicate: " tables_detected[g];}}
                duplicate_found = 1;
                table_duplicate = 1;
                result_b3[0]++;
              }}
            }}
            # If $x was not a duplicate, it is added to the end of the tables_detected array
            {if (duplicate_found == 0){
              tables_detected[array_end] = $x;
              array_end = array_end + 1;
						}}
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

  # Checks if all required tables were detected.
  {for (n in FROM_tables){
    table_found = 0;
    {for (i in tables_detected){
      {if (tables_detected[i] ~ FROM_tables[n]){table_found = 1}}
    }}
    {if (table_found == 0){
      {if (debug_mode == 1){print "\ttable_missing: " FROM_tables[n];}}
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

	}}

  #-----------------------------------------------------------------------------------------------------------------
  # Checks if JOIN table matches ON condition. Checks ON condition columns are correctly paired.

	{if (ON_cols[0] != null){

  # Used when creating array with location of all ON statements.
	{delete columns_detected;}
  array_end = 0;
  # Errors that can be made:
  ON_two_bad_columns = 0;
  ON_one_bad_column = 0;
  ON_duplicate_column = 0;
  ON_table_not_used = 0;
  JOIN_bad_structure = 0;
	ON_column_missing = 0;

	# Creates array of the locations of ON.
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

			# Checks for correct pairing of columns in the ON condition. Detects duplicate columns.
			column_found = 0;
			{for (i = 0; i <= last_element(ON_cols); i = i + 2){
				{if ($n ~ ON_cols[i]){
					duplicate_found = 0;
					# Checks if ON_cols[i] has been found previously.
					{for (g in columns_detected){
						{if (ON_cols[i] == columns_detected[g]){
							duplicate_found++;
							ON_duplicate_column++;
							{if (debug_mode == 1){print "\tON_duplicate_column: " ON_cols[i];}}
							result_b3[0]++;
						}}
					}}
					# If ON_cols[i] has not been found previously, it is added to the array columns_detected.
					{if (duplicate_found == 0){
						columns_detected[array_end] = ON_cols[i];
						array_end++;
						column_found++;
					}}
				}}
				{if ($n ~ ON_cols[i + 1]){
					duplicate_found = 0;
					# Checks if ON_cols[i + 1] has been found previously.
					{for (g in columns_detected){
						{if (ON_cols[i + 1] == columns_detected[g]){
							duplicate_found++;
							ON_duplicate_column++;
							{if (debug_mode == 1){print "\tON_duplicate_column: " ON_cols[i + 1];}}
							result_b3[0]++;
						}}
					}}
					# If ON_cols[i + 1] has not been found previously, it is added to the array columns_detected.
					{if (duplicate_found == 0){
						columns_detected[array_end] = ON_cols[i + 1];
						array_end++;
						column_found++;
					}}
				}}
			}}

			{if (column_found == 0){
				ON_two_bad_columns++;
				{if (debug_mode == 1){print "\tON_two_bad_columns: " $n;}}
				result_b3[0]++;
			}}
			{if (column_found == 1){
				ON_one_bad_columns++;
				{if (debug_mode == 1){print "\tON_one_bad_columns: " $n;}}
				result_b3[0]++;
			}}
			{if (column_found > 2){
				JOIN_bad_structure++;
				{if (debug_mode == 1){print "\tJOIN_bad_structure: More than two columns detected";}}
				result_b3[0]++;
			}}

      # Test if one column of the ON condition is from the table being joined
      {if ($n !~ $(n-2)){
        ON_table_not_used = 1;
        {if (debug_mode == 1){print "\tON_table_not_used"}}
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

			# Checks for correct pairing of columns in the ON condition. Detects duplicate columns.
			column_found = 0;
			{for (i = 0; i <= last_element(ON_cols); i = i + 2){
				{if ($n ~ ON_cols[i] || $(n + 2) ~ ON_cols[i]){
					duplicate_found = 0;
					# Checks if ON_cols[i] has been found previously.
					{for (g in columns_detected){
						{if (ON_cols[i] == columns_detected[g]){
							duplicate_found++;
							ON_duplicate_column++;
							{if (debug_mode == 1){print "\tON_duplicate_column: " ON_cols[i];}}
							result_b3[0]++;
						}}
					}}
					# If ON_cols[i] has not been found previously, it is added to the array columns_detected.
					{if (duplicate_found == 0){
						columns_detected[array_end] = ON_cols[i];
						array_end++;
						column_found++;
					}}
				}}
				{if ($n ~ ON_cols[i + 1] || $(n + 2) ~ ON_cols[i + 1]){
					duplicate_found = 0;
					# Checks if ON_cols[i + 1] has been found previously.
					{for (g in columns_detected){
						{if (ON_cols[i + 1] == columns_detected[g]){
							duplicate_found++;
							ON_duplicate_column++;
							{if (debug_mode == 1){print "\tON_duplicate_column: " ON_cols[i + 1];}}
							result_b3[0]++;
						}}
					}}
					# If ON_cols[i + 1] has not been found previously, it is added to the array columns_detected.
					{if (duplicate_found == 0){
						columns_detected[array_end] = ON_cols[i + 1];
						array_end++;
						column_found++;
					}}
				}}
			}}

			{if (column_found == 0){
				ON_two_bad_columns++;
				{if (debug_mode == 1){print "\tON_two_bad_columns: " $n;}}
				result_b3[0]++;
			}}
			{if (column_found == 1){
				ON_one_bad_columns++;
				{if (debug_mode == 1){print "\tON_one_bad_columns: " $n;}}
				result_b3[0]++;
			}}
			{if (column_found > 2){
				JOIN_bad_structure++;
				{if (debug_mode == 1){print "\tJOIN_bad_structure: More than two columns detected";}}
				result_b3[0]++;
			}}

      # Test if one column of the ON condition is from the table being joined
      table_found_1 = 0;
      table_found_2 = 0;
      {if ($n ~ $(n-2)){table_found_1 = 1}}
      {if ($(n+2) ~ $(n-2)){table_found_2 = 1}}
      {if (table_found_1 + table_found_2 != 1){
        ON_table_not_used = 1;
        {if (debug_mode == 1){print "\tON_table_not_used"}}
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

	# Checks if all required ON condition columns were detected.
	{for (n in ON_cols){
		column_found = 0;
		{for (i in columns_detected){
			{if (ON_cols[n] ~ columns_detected[i]){column_found = 1}}
		}}
		{if (column_found == 0){
			ON_column_missing++;
			{if (debug_mode == 1){print "\tON_column_missing: " ON_cols[n];}}
			result_b3[0]++;
		}}
	}}

  # Print tips
  {if (JOIN_bad_structure > 0){
    print tip("03-004");
  } else {
    {if (ON_two_bad_columns > 0){
      print tip("03-005");
    }}
    {if (ON_one_bad_column > 0){
      print tip("03-005");
    }}
    {if (ON_duplicate_column > 0){
      print tip("03-007");
    }}
    {if (ON_table_not_used > 0){
      print tip("03-006");
    }}
		{if (ON_column_missing > 0){
			print tip("03-009");
		}}
  }}

	}}

} # End of Block 3
