#
# Loden Henning
# GROK Lab 2018
#
# Checks for required number of WHERE and AND statements and that WHERE conditions match what is required.
#

@include "functions.awk"
@include "tips.awk"

function b4_where(debug_mode, result_b4, num_WHERE_req, num_AND_req){

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
