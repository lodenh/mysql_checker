This program checks user MySQL queries for proper syntax and content using a corresponding answer key.

How to run:
    1. Create an answer key following the format of an existing key (read documentation in any "keys/check_X.awk" file).
    2. Create a .txt file in the responses directory containing the MySQL query you would like to correct.
    3. In terminal, cd to the mysql_checker directory.
    4. Run "awk -f keys/check_X.awk responses/myQuery.txt".