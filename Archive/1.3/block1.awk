#
# Loden Henning
# GROK Lab 2018
#
# Checks for SELECT and FROM and that FROM is followed by a table.
#

function b1_select_from(debug_mode, result_b1, num_SELECT_req, num_FROM_req, tables_req, tables_detected){

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
    {if (debug_mode == 1){print "\tSELECT_missing";}}
    SELECT_missing = 1;
    result_b1[0]++;
  }}
  {if (SELECTs_detected > num_SELECT_req){
    {if (debug_mode == 1){print "\tSELECT_extra";}}
    SELECT_extra = 1;
    result_b1[0]++;
  }}
  {if (fld_SELECT != 1 && SELECT_missing == 0){
    {if (debug_mode == 1){print "\tSELECT_misplaced";}}
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
      {if ($n != "SELECT" && $n !~ /\./){
        fld_FROM = n;
        break;}}
    }}
  }}

  {if (FROMs_detected < num_FROM_req){
    {if (debug_mode == 1){print "\tFROM_missing";}}
    FROM_missing = 1;
    result_b1[0]++;
  }}
  {if (FROMs_detected > num_FROM_req){
    {if (debug_mode == 1){print "\tFROM_extra";}}
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
      {if (debug_mode == 1){print "\tFROM_no_table: " $(fld_FROM + 1);}}
      FROM_no_table = 1;
      result_b1[0]++;
    }}
  }}

  # Print tips
  {if (FROM_no_table > 0 AND (FROM_missing > 0 || FROM_extra > 0)){
    print tip("01-004");
  } else {
    {if (FROM_missing > 0 || FROM_extra > 0){
      print tip("01-002");
    }}
    {if (FROM_no_table > 0){
      print tip("01-003");
    }}
  }}

  # Package variables for return
  {result_b1[2] = fld_SELECT;}
  {result_b1[3] = fld_FROM;}

}
