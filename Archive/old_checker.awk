#
#   Loden Henning
#   GROK Lab 2018
#

#   This program checks student submissions for the open response question in quiz 7.1

BEGIN {print "\n--- Start ---\n"}

# Print number of fields in line
{print NR ":\thas " NF " fields"}

# Checks if anything was submitted
!($0 ~ ".") {print NR ":\tDid not attempt"}

# Checks for SELECT statement at beginning of the line
!(tolower($1) ~ /select/) {print NR ":\tmissing SELECT statement"}

# Checks fields 2, 3, 4, 5 for food.name
#{if (tolower($2) ~ /food\.name/) {}
#else if (tolower($3) ~ /food\.name/) {}
#else if (tolower($4) ~ /food\.name/) {}
#else if (tolower($5) ~ /food\.name/) {}
#else
#  {print NR ":\tmissing food.name"}}

# Checks fields 2, 3, 4, 5 for food.name, food.country, nutrition.calories, and restaurants.restaurant
!(tolower($2) ~ /food\.name/ || tolower($3) ~ /food\.name/ || tolower($4) ~ /food\.name/ || tolower($5) ~ /food\.name/) {print NR ":\tmissing food.name"}
!(tolower($2) ~ /food\.country/ || tolower($3) ~ /food\.country/ || tolower($4) ~ /food\.country/ || tolower($5) ~ /food\.country/) {print NR ":\tmissing food.country"}
!(tolower($2) ~ /nutrition\.calories/ || tolower($3) ~ /nutrition\.calories/ || tolower($4) ~ /nutrition\.calories/ || tolower($5) ~ /nutrition\.calories/) {print NR ":\tmissing nutrition.calories"}
!(tolower($2) ~ /restaurants\.restaurant/ || tolower($3) ~ /restaurants\.restaurant/ || tolower($4) ~ /restaurants\.restaurant/ || tolower($5) ~ /restaurants\.restaurant/) {print NR ":\tmissing restaurants.restaurant"}

# Checks fields 2, 3, 4, 5 for unneeded columns
#!(tolower($2) ~ /food\.name/ || tolower($2) ~ /food\.country/ || tolower($2) ~ /nutrition\.calories/ || tolower($2) ~ /restaurants\.restaurant/) && (tolower($2) ~ ".\..") {print NR ":\ta" $2 " is not needed"}
#!(tolower($3) ~ /food\.name/ || tolower($3) ~ /food\.country/ || tolower($3) ~ /nutrition\.calories/ || tolower($3) ~ /restaurants\.restaurant/) && (tolower($2) ~ ".\..") {print NR ":\tb" $3 " is not needed"}
#!(tolower($4) ~ /food\.name/ || tolower($4) ~ /food\.country/ || tolower($4) ~ /nutrition\.calories/ || tolower($4) ~ /restaurants\.restaurant/) && (tolower($2) ~ ".\..") {print NR ":\tc" $4 " is not needed"}
#!(tolower($5) ~ /food\.name/ || tolower($5) ~ /food\.country/ || tolower($5) ~ /nutrition\.calories/ || tolower($5) ~ /restaurants\.restaurant/) && (tolower($2) ~ ".\..") {print NR ":\td" $5 " is not needed"}

# Checks for FROM statement
!(tolower($0) ~ /from/) {print NR ":\tmissing FROM statement"}

# Checks for JOIN statement
!(tolower($0) ~ /join/) {print NR ":\tmissing JOIN statement"}

# Checks for semicolon at end of the line
!/[;]$/ {print NR ":\tmissing semicolon"}

END {print "\n--- Done ---"}
