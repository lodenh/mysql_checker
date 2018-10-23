#
# Loden Henning
# GROK Lab 2018
#
# Checks for required number of WHERE, AND, and OR statements and that WHERE conditions match what is required.
#

function b4_where(debug_mode, result_b4, num_WHERE_req, num_AND_req, num_OR_req, where_cond){

  #-----------------------------------------------------------------------------------------------------------------
  # Checks if line has required number of WHERE and AND statements and that WHERE conditions match what is required.
  #

  WHEREs_detected = 0;
  ANDs_detected = 0;
  ORs_detected = 0;
  # Errors that can be made:
  WHERE_missing = 0;
  WHERE_extra = 0;
  WHERE_bad_col = 0;
  WHERE_bad_relation = 0;
  WHERE_bad_condition = 0;
  AND_missing = 0;
  AND_extra = 0;
  OR_missing = 0;
  OR_extra = 0;

  # Check for WHEREs
  {for (n = 1; n <= NF; n++){
    {if ($n == "where"){WHEREs_detected++}}
  }}
  {if (WHEREs_detected < num_WHERE_req){
    {if (debug_mode == 1){print "\tWHERE_missing";}}
    WHERE_missing = 1;
    result_b4[0]++;
  }}
  {if (WHEREs_detected > num_WHERE_req){
    {if (debug_mode == 1){print "\tWHERE_extra";}}
    WHERE_extra = 1;
    result_b4[0]++;
  }}

  {for (n = 1; n <= NF; n++){
    {if ($n == "where" || $n == "and" || $n == "or"){
      x = n + 1;
      z = last_element(where_cond);

      # If there are no spaces around the relationship (e.g. table.column>=3000)
      {if ($x ~ "=" || $x ~ ">" || $x ~ "<"){
        cond_found = 0;
        {for (i = 0; i < z; i = i + 3){
          {if ($x ~ where_cond[i]){
            cond_found = 1;
            {if ($x !~ where_cond[i+1]){WHERE_bad_relation = 1}}
            {if ($x !~ where_cond[i+2]){WHERE_bad_condition = 1}}
          }}
        }}
        {if (cond_found == 1){WHERE_bad_col = 1}}
      # If there are spaces around the relationship (e.g. table.col >= 3000)
      } else {
          cond_found = 0;
          {for (i = 0; i < z; i = i + 3){
            {if ($x ~ where_cond[i]){
              cond_found = 1;
              {if ($(x + 1) !~ where_cond[i+1]){WHERE_bad_relation = 1}}
              {if ($(x + 2) !~ where_cond[i+2]){WHERE_bad_condition = 1}}
            }}
          }}
          {if (cond_found == 1){WHERE_bad_col = 1}}
      }}
    }}
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
  {if (WHERE_bad_col == 1 && WHERE_bad_relation + WHERE_bad_condition > 1){
    print tip("04-006");
  } else {
    {if (WHERE_bad_col == 1){
      print tip("04-007");
    }}
    {if (WHERE_bad_relation + WHERE_bad_condition > 0){
      print tip("04-008");
    }}
  }}

  # Check for ANDs
  {for (n = 1; n <= NF; n++){
    {if ($n == "and"){ANDs_detected++}}
  }}
  {if (ANDs_detected < num_AND_req){
    {if (debug_mode == 1){print "\tAND_missing";}}
    AND_missing = 1;
    result_b4[0]++;
  }}
  {if (ANDs_detected > num_AND_req){
    {if (debug_mode == 1){print "\tAND_extra";}}
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

  # Check for ORs
  {for (n = 1; n <= NF; n++){
    {if ($n == "or"){ORs_detected++}}
  }}
  {if (ORs_detected < num_OR_req){
    {if (debug_mode == 1){print "\tOR_missing";}}
    OR_missing = 1;
    result_b4[0]++;
  }}
  {if (ORs_detected > num_OR_req){
    {if (debug_mode == 1){print "\tOR_extra";}}
    OR_extra = 1;
    result_b4[0]++;
  }}

  # Print tips
  {if (OR_missing > 0){
    print tip("04-009");
  }}
  {if (OR_extra > 0){
    print tip("04-010");
  }}

}
