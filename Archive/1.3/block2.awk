#
# Loden Henning
# GROK Lab 2018
#
# Checks for required columns between SELECT and FROM.
#

function b2_requestedColumns(debug_mode, result_b2, fld_SELECT, fld_FROM, columns_req, num_JOIN_req){

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
        {if (debug_mode == 1){print "\tnot_col: " $n;}}
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
  {for (n in columns_req) {
    column_found = 0;
    {for (i in columns_detected) {
      {if (columns_detected[i] ~ columns_req[n]){column_found = 1}
      else {}}
    }}
    {if (column_found == 0){
      {if (debug_mode == 1){print "\tcol_missing: " columns_req[n];}}
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

}
