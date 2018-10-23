#
# Loden Henning
# GROK Lab 2018
#
# This function checks students' free response answers for common mistakes.
#

@include "functions.awk"
@include "block1.awk"
@include "block2.awk"
@include "block3.awk"
@include "block4.awk"
@include "block5.awk"

BEGIN{
  # Ignores letter cases (e.g. A == a is true)
  IGNORECASE = 1;

  # Sets field separators to:
  # 1) [space] then [=] then [space]
  # 2) [=]
  # 3) [space]
  # 4) [space] then [=]
  # 5) [=] then [space]
  # 6) [,] then [space]
  FS = "( = )|(=)|( )|( =)|(= )|(, )";

  debug_mode = 0;
}

function checker(num_SELECT_req, num_FROM_req, num_JOIN_req, num_WHERE_req, num_AND_req, num_OR_req, columns_req, tables_req, on_col, where_cond, order_by){

  # critical_error_made acts as a master flag. If it is set to true, no more block functions are called.
  {critical_error_made = 0}

  #-----------------------------------------------------------------------------------------------------------------
  # Checks if anything was submitted.
  #
  {if ($0 ~ /^$/){
    print "Hmmm... Try to submit something--even if you think you'll be wrong.";
    critical_error_made = 1;
    }}

  # awk does not allow us to pass any variable we wish by reference. Instead, arrays are always passed by reference and variables are always passed by value.
  # To overcome this, a standard form of array will be used for feedback from block functions.
  # result_block arrays consist of:
  # [0] = A count of the number of errors found in a block. There isn't a need for a count, but it is just as useful as a bool while being more informative.
  # [1] = Currently unused.
  # [2+] = Any variables that were created in the block that need to be used in another block.

  #-----------------------------------------------------------------------------------------------------------------
  # b1_select_from checks for SELECT and FROM and that FROM is followed by a table.
  #
  {if (critical_error_made == 0){
    {result_b1[0] = 0;}
    {b1_select_from(debug_mode, result_b1, num_SELECT_req, num_FROM_req, tables_req, tables_detected);}
    {fld_SELECT = result_b1[2];}
    {fld_FROM = result_b1[3];}
    {if (debug_mode == 1){print "B1 Errors: " result_b1[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # b2_requestedColumns checks for required columns between SELECT and FROM.
  #
  {if (critical_error_made == 0){
    {result_b2[0] = 0;}
    {b2_requestedColumns(debug_mode, result_b2, fld_SELECT, fld_FROM, columns_req, num_JOIN_req);}
    {if (debug_mode == 1){print "B2 Errors: " result_b2[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # b3_tableJoined checks if all tables are joined, if ON condition matches JOIN table, and JOIN structure.
  #
  {if (critical_error_made == 0){
    {result_b3[0] = 0;}
    {b3_tableJoined(debug_mode, result_b3, tables_req, on_col);}
    {if (debug_mode == 1){print "B3 Errors: " result_b3[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # b4_where checks for required number of WHERE and AND statements and that WHERE conditions match what is required.
  #
  {if (critical_error_made == 0){
    {result_b4[0] = 0;}
    {b4_where(debug_mode, result_b4, num_WHERE_req, num_AND_req);}
    {if (debug_mode == 1){print "B4 Errors: " result_b4[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # b5_orderby checks for correct ORDER BY column and sort direction.
  #
  {if (critical_error_made == 0){
    {result_b5[0] = 0;}
    {b5_orderby(debug_mode, order_by);}
    {if (debug_mode == 1){print "BS Errors: " result_b5[0]}}
    {if (debug_mode == 1){print ""}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # Checks for semicolon at end of the line
  #
  {if (critical_error_made == 0){
    {if ($0 !~ /;$/){print "Oops! Looks like you're missing a semicolon."}}
  }}

  #-----------------------------------------------------------------------------------------------------------------
  # Clean up
  #
  {delete columns_detected;}
  {delete tables_detected;}


  # If no errors were detected, print a congratulation
  {if ((result_b1[0] + result_b2[0] + result_b3[0] + result_b4[0]) == 0){print "Nice one!"}}

}
