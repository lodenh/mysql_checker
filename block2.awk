#
# Loden Henning
# GROK Lab 2018
#
# Checks for required SELECT columns, CREATE TABLE columns and datatypes, INSERT columns and values, UPDATE columns and values.
#

function b2_columns(debug_mode, result_b2, command, fld_SELECT, fld_FROM, SELECT_cols, CREATE_cols, UPDATE_cols, num_JOIN_req){

  #-----------------------------------------------------------------------------------------------------------------
  # Tests if all required SELECT columns are requested. Detects duplicates.
  # Note: This doesn't work correctly when the user input has no FROM
  #		(default fld_FROM = first field that is not SELECT or field containing "." (table.column))
  #

	{if (SELECT_cols[0] != null){

  {delete columns_detected;}
  array_end = 0;
  # Errors that can be made:
  col_missing = 0;
  col_unnecessary = 0;
  col_duplicate = 0;
  not_col = 0;

  # Tests all fields between SELECT and FROM
  {for (n = (fld_SELECT + 1); n < fld_FROM; n++){
    column_found = 0;
    duplicate_found = 0;
    not_col_temp = 0;
    # Tests if $n has a period signifying it's a table.column
    {if (num_JOIN_req != 0){
      {if ($n !~ /\./ && $n != "distinct"){
        {if (debug_mode == 1){print "\tnot_col: " $n;}}
        not_col = 1;
        not_col_temp = 1;
        result_b2[0]++;
      }}
    }}
		# Ignore DISTINCT.
		{if ($n == "distinct"){not_col_temp = 1}}
    # Tests if $n matches a required column
    {if (not_col_temp == 0){
      {for (i in SELECT_cols){
#        print $n " vs " SELECT_cols[i];
        {if ($n ~ SELECT_cols[i]){
#          print "TRUE ^";
          column_found = 1;
          # Tests if the column found ($n) has already been detected on this line
          {for (g in columns_detected){
            # columns_detected contains columns that are required and have been found in the user's input
            {if ($n ~ columns_detected[g]){
              {if (debug_mode == 1){print "\tcol_duplicate: " $n;}}
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
      {if (debug_mode == 1){print "\tcol_unnecessary: " $n;}}
      col_unnecessary = 1;
      result_b2[0]++;
    }}
  }}

  # Checks if all required columns were detected
  {for (n in SELECT_cols) {
    column_found = 0;
    {for (i in columns_detected) {
      {if (columns_detected[i] ~ SELECT_cols[n]){column_found = 1}
      else {}}
    }}
    {if (column_found == 0){
      {if (debug_mode == 1){print "\tcol_missing: " SELECT_cols[n];}}
      col_missing = 1;
      result_b2[0]++;
    }}
  }}

  # Print tips
  {if (col_unnecessary > 0){
    print tip("02-002");
  } else {
    {if (col_missing > 0){
      print tip("02-001");
    }}
  }}
  {if (col_duplicate > 0){
    print tip("02-003");
  }}
  {if (not_col > 0){
    print tip("02-004");
  }}

	}}

######################################################################################################################################

	# Checks 'CREATE TABLE table (col1 datatype, col2 datatype, ...)' has all cols and associated datatypes.

	{if (command[0] == "create" && command[1] == "table"){

		parenthesis_start_found = 0;
		parenthesis_end_found = 0;
		fld_p_start = 0;
		fld_p_end = 0;
		# Errors that can be made:
		no_parenthesis = 0;
		CREATE_missing_column = 0;
		CREATE_bad_column = 0;
		CREATE_bad_datatype = 0;

		# Checks for opening and closing parenthesis and records their field.
		{for (n = 1; n <= NF; n++){
			{if ($n ~ /\(/){
				parenthesis_start_found++;
				fld_p_start = n;
			}}
			{if ($n !~ /)/){
				parenthesis_end_found++;
				fld_p_end = n;
			}}
		}}
		{if (parenthesis_start != 1 || parenthesis_end != 1){
			no_parenthesis++;
			{if (debug_mode == 1){print "\tno_parenthesis";}}
			result_b2[0]++;
		}}

		{if (fld_p_start != 0 && fld_p_end != 0){
			num_fields = fld_p_end - fld_p_start;
			{if (num_fields != last_element(CREATE_cols)){
				CREATE_missing_column++;
				{if (debug_mode == 1){print "\tCREATE_missing_column";}}
				result_b2[0]++;
			}}
			{for (n = 0; n <= num_fields; n++){
				{if ($(n + fld_p_start) !~ CREATE_cols[n]){
					{if (n%2 == 0){
						CREATE_bad_column++;
						{if (debug_mode == 1){print "\tCREATE_bad_column: " $(n + fld_p_start);}}
						result_b2[0]++;
					} else {
						CREATE_bad_datatype++;
						{if (debug_mode == 1){print "\tCREATE_bad_datatype: " $(n + fld_p_start - 1) " " $(n + fld_p_start);}}
						result_b2[0]++;
					}}
				}}
			}}
		}}

		# Print tips
		{if (no_parenthesis > 0){print tip("02-005")}}
		{if (CREATE_missing_column > 0){print tip("02-009")}
		else {
			{if (CREATE_bad_column > 0 && CREATE_bad_datatype > 0){print tip("02-006")}
			else {
				{if (CREATE_bad_column > 0){print tip("02-007")}}
				{if (CREATE_bad_datatype > 0){print tip("02-008")}}
			}}
		}}

	}}

#################################################################################################################

	# Checks for required columns and associated values in INSERT queries.

	{if (command[0] == "insert"){

		fld_VALUES = 0;
		fld_INTO = 0;
		VALUES_found = 0
		p_found = 0;
		INTO_p_start_found = 0;
		INTO_p_end_found = 0;
		VALUES_p_start_found = 0;
		VALUES_p_end_found = 0;
		fld_p_start_INTO = 0;
		fld_p_end_INTO = 0;
		fld_p_start_VALUES = 0;
		fld_p_end_VALUES = 0;
		#Errors that can be made:
		missing_VALUES = 0;
		extra_VALUES = 0;
		VALUES_p_start_missing = 0;
		VALUES_p_end_missing = 0;
		INTO_p_start_missing = 0;
		INTO_p_end_missing = 0;
		INSERT_missing_column = 0;
		INSERT_bad_col = 0;
		INSERT_bad_val = 0;
		columns_not_needed = 0; # If * but student tries listing columns

		# Counts amount of VALUES in line. Sets fld_VALUES, fld_INTO.
		{for (n = 0; n <= NF; n++){
			{if ($n == "values"){
				fld_VALUES = n;
				VALUES_found++;
			} else if ($n == "into"){
				fld_INTO = n;
			}}
		}}
		{if (VALUES_found < 1){
			missing_VALUES++;
			{if (debug_mode == 1){print "\tmissing_VALUES";}}
			result_b2[0]++;
		}}
		{if (VALUES_found > 1){
			extra_VALUES++;
			{if (debug_mode == 1){print "\textra_VALUES";}}
			result_b2[0]++;
		}}

		# If inserting into all columns thus not needing the columns to be listed "... INTO table1 (col1, col2, col3) VALUES ...".
		{if (VALUES_found == 1){

			# Checks for ( in the fields after VALUES.
			{for (n = (fld_VALUES + 1); n <= NF; n++){
				{if ($n ~ /\(/){
					VALUES_p_start_found++;
					{if ($n == "("){fld_p_start_VALUES = n + 1}
					else {fld_p_start_VALUES = n}}
				}}
			}}
			{if (VALUES_p_start_found != 1){
				VALUES_p_start_missing++;
				{if (debug_mode == 1){print "\tVALUES_p_start_missing";}}
				result_b2[0]++;
			}}
			# Checks for ) in the fields after VALUES.
			{for (n = (fld_VALUES + 1); n <= NF; n++){
				{if ($n ~ /\)/){
					VALUES_p_end_found++;
					{if ($n == ")"){fld_p_end_VALUES = n - 1}
					else {fld_p_end_VALUES = n}}
				}}
			}}
			{if (VALUES_p_end_found != 1){
				VALUES_p_end_missing++;
				{if (debug_mode == 1){print "\tVALUES_p_end_missing";}}
				result_b2[0]++;
			}}

			{if (INSERT_cols[0] == "*"){

				# Checks for required values within parenthesis after VALUES.
				num_fields = fld_p_end_VALUES - fld_p_start_VALUES;
				{if (num_fields != last_element(INSERT_vals)){
					INSERT_missing_column++;
					{if (debug_mode == 1){print "\tINSERT_missing_column";}}
					result_b2[0]++;
				}}
				{for (n = 0; n < num_fields; n++){
					{if ($(n + fld_p_start_VALUES) !~ INSERT_vals[n]){
						INSERT_bad_val++;
						{if (debug_mode == 1){print "\tINSERT_bad_val: " $(n + fld_VALUES + 1);}}
						result_b2[0]++;
					}}
				}}

				# Checks if student listed columns instead of using *.
				p_found = 0;
				{for (n = fld_INTO + 1; n < fld_VALUES; n++){
					{if ($n ~ /\(/){p_found++}}
				}}
				{if (p_found == 0){
					columns_not_needed++;
					{if (debug_mode == 1){print "\tcolumns_not_needed";}}
					result_b2[0]++;
				}}

			} else {

				# Checks for ( in the fields after INTO but before VALUES.
				{for (n = (fld_INTO + 1); n < fld_VALUES; n++){
					{if ($n ~ /\(/){
						INTO_p_start_found++;
						{if ($n == "("){fld_p_start_INTO = n + 1}
						else {fld_p_start_INTO = n}}
					}}
				}}
				{if (INTO_p_start_found != 1){
					INTO_p_start_missing++;
					{if (debug_mode == 1){print "\tINTO_p_start_missing: " $(fld_INTO) " " $(fld_INTO + 1) " " $(fld_INTO + 2);}}
					result_b2[0]++;
				}}
				# Checks for one ) after INTO but before fld_VALUES.
				{for (n = (fld_INTO + 1); n < fld_VALUES; n++){
					{if ($n ~ /\)/){
						INTO_p_end_found++;
						{if ($n == ")"){fld_p_end_INTO = n - 1}
						else {fld_p_end_INTO = n}}
					}}
				}}
				{if (INTO_p_end_found != 1){
					INTO_p_end_missing++;
					{if (debug_mode == 1){print "\tINTO_p_end_missing";}}
					result_b2[0]++;
				}}

				# Checks the number of fields within () after INTO equals the number of columns that need to be inserted.
				# Checks each column or value matches the corresponding correct column or value.
				{if (fld_p_start_INTO != 0 && fld_p_end_INTO != 0){
					num_fields = fld_p_end_INTO - fld_p_start_INTO;
					{if (num_fields != last_element(INSERT_cols)){
						INSERT_missing_column++;
						{if (debug_mode == 1){print "\tINSERT_missing_column";}}
						result_b2[0]++;
					}}
					{for (n = 0; n < num_fields; n++){
						{if ($(n + fld_p_start_INTO) !~ INSERT_cols[n]){
							INSERT_bad_col++;
							{if (debug_mode == 1){print "\tINSERT_bad_col: " $(n + fld_p_start_INTO);}}
							result_b2[0]++;
						}}
						{if ($(n + fld_p_start_VALUES) !~ INSERT_vals[n]){
							INSERT_bad_val++;
							{if (debug_mode == 1){print "\tINSERT_bad_val: " $(n + fld_p_start_VALUES);}}
							result_b2[0]++;
						}}
					}}
				}}

			}}
		}}

		# Print tips
		{if (missing_VALUES > 0){print tip("02-010")}}
		{if (extra_VALUES > 0){print tip("02-011")}}
		{if ((INTO_p_start_missing > 0 || INTO_p_end_missing > 0) && (VALUES_p_start_missing > 0 || VALUES_p_end_missing > 0)){print tip("02-023")}
		else {
			{if (INTO_p_start_missing > 0 || INTO_p_end_missing > 0){print tip("02-013")}}
			{if (VALUES_p_start_missing > 0 || VALUES_p_end_missing > 0){print tip("02-012")}}
		}}
		{if (INSERT_missing_column > 0){print tip("02-014")}} #"make sure have all columns and associated values".
		{if (INSERT_bad_col > 0 && INSERT_bad_val > 0){print tip("02-022")}
		else {
			{if (INSERT_bad_col > 0){print tip("02-015")}}
			{if (INSERT_bad_val > 0){print tip("02-016")}}
		}}
		{if (columns_not_needed > 0){print tip("02-017")}}

	}}

	#################################################################################################################

	# Checks for required columns and associated values in UPDATE queries.
	# NOTE: Does not support students using both 'col=val' and 'col = val' structures within SET in the same line.

	{if (command[0] == "update"){

		{delete columns_detected;}
		fld_SET = 0;
		fld_WHERE = 0;
		column_found = 0;
		array_end = 0;
		# Errors that can be made:
		UPDATE_bad_column = 0;
		UPDATE_bad_value = 0;
		UPDATE_duplicate_column = 0;

		# Set fld_SET and fld_WHERE.
		{for (n = 1; n <= NF; n++){
			{if ($n == "set"){fld_SET = n}}
			{if ($n == "where"){fld_WHERE = n}}
		}}

		{if (fld_SET != 0 && fld_WHERE != 0){

			# If field after SET contains "=" we assume structure 'SET col1=val1, col2=val2, ...'.
			{if ($(fld_SET + 1) ~ "="){

				{for (n = (fld_SET + 1); n < fld_WHERE; n++){
					column_found = 0;
					{for (i = 0; i <= last_element(UPDATE_cols); i = i + 2){

						{if ($n ~ UPDATE_cols[i]){
							duplicate_found = 0;
							# Checks if UPDATE_cols[i] has been found previously.
							{for (g in columns_detected){
								{if (UPDATE_cols[i] == columns_detected[g]){
									duplicate_found++;
									UPDATE_duplicate_column++;
									{if (debug_mode == 1){print "\tUPDATE_duplicate_column: " UPDATE_cols[i];}}
									result_b2[0]++;
								}}
							}}
							# If UPDATE_cols[i] has not been found previously, it is added to the array columns_detected.
							{if (duplicate_found == 0){
								columns_detected[array_end] = UPDATE_cols[i];
								array_end++;
								column_found++;
							}}

							# Checks if the associated value is in field $n.
							{if ($n !~ UPDATE_cols[i + 1]){
								UPDATE_bad_value++;
								{if (debug_mode == 1){print "\tUPDATE_bad_value: " $n " is missing " UPDATE_cols[i + 1];}}
								result_b2[0]++;
							}}
						}}

					}}
					{if (column_found == 0){
						UPDATE_bad_column++;
						{if (debug_mode == 1){print "\tUPDATE_bad_column: " $n " does not contain a needed column.";}}
						result_b2[0]++;
					}}

				}}

			# If field after SET does not contain "=" we assume structure 'SET col1 = val1, col2 = val2, ...'.
			} else {

				{for (n = (fld_SET + 1); n < fld_WHERE; n = n + 3){
					column_found = 0;
					{for (i = 0; i <= last_element(UPDATE_cols); i = i + 2){

						{if ($n ~ UPDATE_cols[i]){
							duplicate_found = 0;
							# Checks if UPDATE_cols[i] has been found previously.
							{for (g in columns_detected){
								{if (UPDATE_cols[i] == columns_detected[g]){
									duplicate_found++;
									UPDATE_duplicate_column++;
									{if (debug_mode == 1){print "\tUPDATE_duplicate_column: " UPDATE_cols[i];}}
									result_b2[0]++;
								}}
							}}
							# If UPDATE_cols[i] has not been found previously, it is added to the array columns_detected.
							{if (duplicate_found == 0){
								columns_detected[array_end] = UPDATE_cols[i];
								array_end++;
								column_found++;
							}}

							# Checks if the associated value is in field $(n + 2).
							{if ($(n + 2) !~ UPDATE_cols[i + 1]){
								UPDATE_bad_value++;
								{if (debug_mode == 1){print "\tUPDATE_bad_value: " $(n + 2) " is missing " UPDATE_cols[i + 1];}}
								result_b2[0]++;
							}}
						}}

					}}

					{if (column_found == 0){
						UPDATE_bad_column++;
						{if (debug_mode == 1){print "\tUPDATE_bad_column: " $n;}}
						result_b2[0]++;
					}}

				}}

			}}
		}}

		# Print tips
		{if (UPDATE_bad_column > 0 && UPDATE_bad_value > 0){print tip("02-021")}
		else {
			{if (UPDATE_bad_column > 0){print tip("02-018")}}
			{if (UPDATE_bad_value > 0){print tip("02-019")}}
		}}
		{if (UPDATE_duplicate_column > 0){print tip("02-020")}}

	}}

} # End of Block 2
