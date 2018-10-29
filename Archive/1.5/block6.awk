#
# Loden Henning
# GROK Lab 2018
#
# Checks for correct comma placement.
#

function block6(debug_mode, result_b6, command, fld_SELECT, fld_FROM){

	# Errors that can be made:
	comma_missing = 0;		# Comma is not found where one is needed.
	comma_misplaced = 0;	# Comma is found in a field where one is not needed.
	comma_not_needed = 0;	# Comma is found in query that should never need one (SHOW, USE, DELETE).
	open_parentheses = 0;	# Number of opening and number of closing parentheses are not the same.

	{if (command[0] == "show" || command[0] == "use" || command[0] == "delete"){

		# Tests if any field in line contains a comma as SHOW, USE, and DELETE should never require one.
		{for (n = 1; n <= NF; n++){
			{if ($n ~ /\,/){
				comma_not_needed++;
		        {if (debug_mode == 1){print "\tcomma_not_needed: " $n}}
		        result_b6[0]++;
			}}
		}}

	} else if (command[0] == "select"){

		# Test if the field before FROM ends with a comma.
		{if ((fld_FROM - fld_SELECT) >= 2){
			n = fld_FROM - 1;
			{if ($n ~ /\,$/){
				comma_misplaced++;
		        {if (debug_mode == 1){print "\tcomma_misplaced: " $n}}
		        result_b6[0]++;
			}}
		}}

		{if ((fld_FROM - fld_SELECT) >= 3){
			{for (n = fld_FROM - 2; n > fld_SELECT; n--){
				{if ($n !~ /\,$/){
					comma_missing++;
			        {if (debug_mode == 1){print "\tcomma_missing: " $n}}
			        result_b6[0]++;
				}}
			}}
		}}

	} else if (command[0] == "insert"){
	# INSERT INTO mytable (col1,col2) VALUES (val1,val2);

		# Get locations of content within parentheses.
		delete start_looking_for_commas;
		delete stop_looking_for_commas;
		{for (n = 1; n <= NF; n++){
			array_end_start_looking = arraylength(start_looking_for_commas);
			array_end_stop_looking = arraylength(stop_looking_for_commas);
			{if ($n ~ /\(/){
				{if ($n == "("){start_looking_for_commas[array_end_start_looking] = n + 1}
				else {start_looking_for_commas[array_end_start_looking] = n}}
			}}
			{if ($n ~ /\)/){
				{if ($n == ")"){stop_looking_for_commas[array_end_stop_looking] = n - 2}
				else {stop_looking_for_commas[array_end_stop_looking] = n - 1}}
			}}
		}}

		# Check for same amount of opening and closing parentheses.
		array_end_start_looking = arraylength(start_looking_for_commas);
		array_end_stop_looking = arraylength(stop_looking_for_commas);
		{if (array_end_start_looking != array_end_stop_looking){
			open_parentheses++;
			{if (debug_mode == 1){print "\topen_parentheses"}}
			result_b6[0]++;
		}}

		# Check for commas where needed within parentheses.
		{if ((open_parentheses == 0) && (array_end_start_looking != 0)){
			# Go through all sets of parentheses.
			{for (x = 0; x <= array_end_start_looking; x++){
				# Go through all fields within a set of parentheses.
				{for (i = start_looking_for_commas[x]; i <= stop_looking_for_commas[x]; i++){
					{if (($i !~ /\,$/) && (length(i) != 0)){
						comma_missing++;
				        {if (debug_mode == 1){print "\tcomma_missing: $" i " " $i}}
				        result_b6[0]++;
					}}
				}}
			}}
		}}

		# Checks for a comma directly before closing parentheses.
		{for (n = 1; n <= NF; n++){
			{if ($n ~ /\,\)/){
				comma_misplaced++;
				{if (debug_mode == 1){print "\tcomma_misplaced: " $n}}
				result_b6[0]++;
			} else if (($n ~ /\,$/) && ($(n+1) == ")")){
				comma_misplaced++;
				{if (debug_mode == 1){print "\tcomma_misplaced: " $n}}
				result_b6[0]++;
			}}
		}}

	} else if (command[0] == "update"){

		fld_SET = 0;
		fld_WHERE = 0;

		# Remember locations of first SET and last WHERE.
		{for (n = 1; n <= NF; n++){
			{if (($n == "set") && (fld_SET == 0)){fld_SET = n}}
			{if ($n == "where"){fld_WHERE = n}}
		}}

		{if ((fld_SET != 0) && (fld_WHERE != 0)){
			# If only one field between SET and WHERE: SET col1=val1,col2=val2 WHERE ... ;
			{if (fld_WHERE - fld_SET <= 2){
				n = fld_WHERE - 1;
				{if ($n ~ /\,$/){
					comma_misplaced++;
			        {if (debug_mode == 1){print "\tcomma_misplaced: " $n}}
			        result_b6[0]++;
				}}
			}}

			# If two or more fields between SET and WHERE: SET col1=val1, col2=val2 WHERE ... ; or SET col1 = val1, col2 = val2 WHERE ... ;
			x = fld_SET + 1;
			# If field after SET contains "=", assume format: SET col1=val1, col2=val2, ... WHERE ... ;
			{if ($x ~ /=/){
				{for (n = x; n < (fld_WHERE - 1); n++){
					{if ($n !~ /\,$/){
						comma_missing++;
				        {if (debug_mode == 1){print "\tcomma_missing: " $n}}
				        result_b6[0]++;
					}}
				}}
			# If field after SET does not contain "=", assume format: SET col1 = val1, col2 = val2, ... WHERE ... ;
			} else {
				# Test fields that contain column names. These should not contain commas.
				{for (n = fld_SET + 1; n < fld_WHERE; n = n + 3){
					{if ($n ~ /\,/){
						comma_misplaced++;
				        {if (debug_mode == 1){print "\tcomma_misplaced: " $n}}
				        result_b6[0]++;
					}}
				}}
				# Test fields that contain "=". These should not contain commas.
				{for (n = fld_SET + 2; n < fld_WHERE; n = n + 3){
					{if ($n ~ /\,/){
						comma_misplaced++;
						{if (debug_mode == 1){print "\tcomma_misplaced: " $n}}
						result_b6[0]++;
					}}
				}}
				# Test fields that contain values. These should contain commas.
				{for (n = fld_SET + 3; n < (fld_WHERE - 1); n = n + 3){
					{if ($n !~ /\,$/){
						comma_missing++;
						{if (debug_mode == 1){print "\tcomma_missing: " $n}}
						result_b6[0]++;
					}}
				}}
			}}
		}}

	} else if (command[0] == "create"){

		CREATE_opening_p = 0;
		CREATE_closing_p = 0;

		# Test for opening and closing set of parentheses for format of: CREATE TABLE myTable (col1 datatype, col2 datatype);
		{for (n = 1; n <= NF; n++){
			# Remember first encountered opening parenthesis.
			{if (($n ~ /\(/) && (CREATE_opening_p == 0)){CREATE_opening_p = n}}
			# Remember last encountered closig parenthesis.
			{if ($n ~ /\)/){CREATE_closing_p = n}}
		}}

		{if ((CREATE_opening_p != 0) && (CREATE_closing_p != 0)){

			# If zero or one column+datatype pair: CREATE TABLE myTable (col1 datatype);
			{if (CREATE_closing_p - CREATE_opening_p < 2){
				{if ($CREATE_opening_p ~ /\,/){
					comma_misplaced++;
					{if (debug_mode == 1){print "\tcomma_misplaced: " $CREATE_opening_p}}
					result_b6[0]++;
				}}
				{if ($CREATE_closing_p ~ /\,/){
					comma_misplaced++;
					{if (debug_mode == 1){print "\tcomma_misplaced: " $CREATE_closing_p}}
					result_b6[0]++;
				}}
			}}

			# If two or more column+datatype pairs: CREATE TABLE myTable (col1 datatype, col2 datatype);
			{if (CREATE_closing_p - CREATE_opening_p >= 2){
				# Test fields that contain column names. They should not contain commas.
				{for (n = CREATE_opening_p; n < CREATE_closing_p; n = n + 2){
					{if ($n ~ /\,/){
						comma_misplaced++;
						{if (debug_mode == 1){print "\tcomma_misplaced: " $n}}
						result_b6[0]++;
					}}
				}}
				# Test fields that contain databases. They should contain commas except for the last one.
				{for (n = CREATE_opening_p + 1; n < CREATE_closing_p; n = n + 2){
					{if ($n !~ /\,/){
						comma_missing++;
						{if (debug_mode == 1){print "\tcomma_missing: " $n}}
						result_b6[0]++;
					}}
				}}
			}}

		} else {
			{if ((debug_mode == 1) && (command[1] == "table")){print "Both an opening and a closing parenthesis was not detected."}}
		}}

	}}

	# Print tips.
	{if (comma_not_needed > 0){
      print tip("06-001");
    }}
	{if (comma_misplaced > 0){
	  print tip("06-002");
	}}
	{if (comma_missing > 0){
	  print tip("06-003");
	}}
	{if (open_parentheses > 0){
	  print tip("06-004");
	}}

} # End of Block 6
