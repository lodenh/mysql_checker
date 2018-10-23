#
# Loden Henning
# GROK Lab 2018
#
# Checks for correct ORDER BY column and sort direction.
#

function block5(debug_mode, result_b5, ORDERBY_cond){

  ORDERs_detected = 0;
  # Errors that can be made
  ORDER_missing = 0;
  ORDER_extra = 0;
  ORDER_bad_structure = 0;
  ORDER_bad_column = 0;
  ORDER_bad_sort = 0;

  {if (ORDERBY_cond[0] != null){

    {for (n = 1; n <= NF; n++){
      {if ($n == "order"){
        ORDERs_detected++;
        {if ($(n+1) != "by"){ORDER_bad_structure = 1}
        else {
          if ($(n+2) !~ ORDERBY_cond[0]){ORDER_bad_column = 1}
          if (ORDERBY_cond[1] == 0){
            if ($(n+3) == "desc"){ORDER_bad_sort = 1}
          }
          if (ORDERBY_cond[1] == 1){
            if ($(n+3) != "desc"){ORDER_bad_sort = 1}
          }
        }}
      }}
    }}

    {if (ORDERs_detected < 1){
      {if (debug_mode == 1){print "\tORDER_missing";}}
      ORDER_missing = 1;
      result_b5[0]++;
    }}
    {if (ORDERs_detected > 1){
      {if (debug_mode == 1){print "\tORDER_extra";}}
      ORDER_extra = 1;
      result_b5[0]++;
    }}
    {if (ORDER_bad_structure == 1){
      {if (debug_mode == 1){print "\tORDER_bad_structure";}}
      result_b5[0]++;
    }}
    {if (ORDER_bad_column == 1){
      {if (debug_mode == 1){print "\tORDER_bad_column";}}
      result_b5[0]++;
    }}
    {if (ORDER_bad_sort == 1){
      {if (debug_mode == 1){print "\tORDER_bad_sort";}}
      result_b5[0]++;
    }}

  }}

  # Print tips
  {if (ORDER_missing > 0){
    print tip("05-001");
  }}
  {if (ORDER_extra > 0){
    print tip("05-002");
  }}
  {if (ORDER_bad_structure > 0){
    print tip("05-003");
  }}
  {if (ORDER_bad_column > 0){
    print tip("05-004");
  }}
  {if (ORDER_bad_sort > 0){
    print tip("05-005");
  }}

} # End of Block 5
