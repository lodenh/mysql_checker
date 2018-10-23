#
# Loden Henning
# GROK Lab 2018
#
# This function checks students' free response answers for common mistakes.
#

@include "../Quiz Checker/functions.awk"
@include "../Quiz Checker/tips.awk"
@include "../Quiz Checker/block1.awk"
@include "../Quiz Checker/block2.awk"
@include "../Quiz Checker/block3.awk"
@include "../Quiz Checker/block4.awk"
@include "../Quiz Checker/block5.awk"
@include "../Quiz Checker/block6.awk"

BEGIN {
	# Ignores letter cases (e.g. A == a is true)
	IGNORECASE = 1;

	# Sets field separators to:
	# 1) [space]
	# 2) [space] then [space]
	# 3) [,] then [space]
	# 4) [,]
	FS = "( )|(  )|(, )|(,)";

	debug_mode = 1;
}

function checker(command, SELECT_cols, FROM_tables, ON_cols, CREATE_cols, UPDATE_cols, INSERT_cols, INSERT_vals, WHERE_cond, ORDERBY_cond, num_JOIN_req, num_WHERE_req, num_AND_req, num_OR_req){

	{if(debug_mode==1){print "\n\n---------------LINE " NR "---------------"}}

	# awk does not allow us to pass any variable we wish by reference. Instead, arrays are always passed by reference and variables are always passed by value.
	# To overcome this, a standard form of array will be used for feedback from block functions.
	# result_bX arrays consist of:
	# [0] = A count of the number of errors found in a block. There isn't a need for a count, but it is just as useful as a bool while being more informative.
	# [1+] = Any variables that were created in the block that need to be used in another block.

	# result_b0 acts as a master flag. If it is changed from a value of 0, no subsequent block functions will be called.
	{result_b0[0] = 0}

	#-----------------------------------------------------------------------------------------------------------------
	# Checks if anything was submitted.
	#
	{if ($0 ~ /^$/){
		print "Hmmm... Try to submit something--even if you think you'll be wrong.";
		result_b0[0]++;
	}}

	#-----------------------------------------------------------------------------------------------------------------
	# block1 checks for required command (e.g. SELECT, SHOW, UPDATE, etc.) and associated syntax.
	#
	{if (result_b0[0] == 0){
		{result_b1[0] = 0;}
		{block1(debug_mode, result_b1, command, FROM_tables, tables_detected);}
		{fld_SELECT = result_b1[1];}
		{fld_FROM = result_b1[2];}
		{if (debug_mode == 1){print "^ B1 Errors: " result_b1[0]}}
		{if (debug_mode == 1){print ""}}
	}}

	#-----------------------------------------------------------------------------------------------------------------
	# block2 checks for required SELECT columns, CREATE TABLE columns and datatypes, INSERT columns and values, UPDATE columns and values.
	#
	{if (result_b0[0] == 0){
		{result_b2[0] = 0;}
		{block2(debug_mode, result_b2, command, fld_SELECT, fld_FROM, SELECT_cols, CREATE_cols, UPDATE_cols, num_JOIN_req);}
		{if (debug_mode == 1){print "^ B2 Errors: " result_b2[0]}}
		{if (debug_mode == 1){print ""}}
	}}

	#-----------------------------------------------------------------------------------------------------------------
	# block3 checks if all tables are joined, JOIN structure, ON condition columns, and if ON condition matches JOIN table.
	#
	{if (result_b0[0] == 0){
		{result_b3[0] = 0;}
		{block3(debug_mode, result_b3, FROM_tables, ON_cols);}
		{if (debug_mode == 1){print "^ B3 Errors: " result_b3[0]}}
		{if (debug_mode == 1){print ""}}
	}}

	#-----------------------------------------------------------------------------------------------------------------
	# block4 checks for required number of WHERE, AND, and OR statements and that WHERE conditions match what is required.
	#
	{if (result_b0[0] == 0){
		{result_b4[0] = 0;}
		{block4(debug_mode, result_b4, num_WHERE_req, num_AND_req, num_OR_req, WHERE_cond);}
		{if (debug_mode == 1){print "^ B4 Errors: " result_b4[0]}}
		{if (debug_mode == 1){print ""}}
	}}

	#-----------------------------------------------------------------------------------------------------------------
	# block5 checks for correct ORDER BY column and sort direction.
	#
	{if (result_b0[0] == 0){
		{result_b5[0] = 0;}
		{block5(debug_mode, result_b5, ORDERBY_cond);}
		{if (debug_mode == 1){print "^ B5 Errors: " result_b5[0]}}
		{if (debug_mode == 1){print ""}}
	}}

	#-----------------------------------------------------------------------------------------------------------------
	# block6 checks for correct comma placement.
	#
	{if (result_b0[0] == 0){
		{result_b6[0] = 0;}
		{block6(debug_mode, result_b6, command, fld_SELECT, fld_FROM);}
		{if (debug_mode == 1){print "^ B6 Errors: " result_b6[0]}}
		{if (debug_mode == 1){print ""}}
	}}

	#-----------------------------------------------------------------------------------------------------------------
	# Checks for semicolon at end of the line.
	#
	{if (result_b0[0] == 0){
# This doesn't check if the line ends with a semicolon--only if the line contains one.
		{if ($0 !~ /;/){
			print "• Oops! Looks like you're missing a semicolon.";
			result_b0[0]++;
		}}
	}}

	#-----------------------------------------------------------------------------------------------------------------
	# Clean up
	#
	{delete columns_detected;}
	{delete tables_detected;}


	# If no errors were detected, print a congratulation
	{if ((result_b0[0] + result_b1[0] + result_b2[0] + result_b3[0] + result_b4[0] + result_b5[0] + result_b6[0]) == 0){print "Nice one!"}}

}
