#
# Loden Henning
# GROK Lab 2018
#
# This function takes an error code and returns the corresponding tip
#

# Codes are structured in the form "00-000" where the first two digits are the block number and the following three are the error
function tip(code){
  switch (code){
    # BLOCK 1: SELECT, FROM
    case "01-001":
      return "Remember, to get columns from tables, your query should begin with \"SELECT\".";
    case "01-002":
      return "Double check that your query contains one \"FROM\" statement after listing the columns you would like to get.";
    case "01-003":
      return "Double check that your \"FROM\" statement is followed by a table you are requesting columns from.";
    case "01-004":
      return "Double check your query contains one \"FROM\" statement after listing the columns you want to get. \"FROM\" should then be followed by a table you are requesting columns from.";

    # BLOCK 2: Columns between SELECT and FROM
    case "02-001":
      return "Make sure you requested all the columns you need.";
    case "02-002":
      return "Whoops! It looks like you requested a column that you don't need or you misspelled one that you do. Remember it's 'table.column'.";
    case "02-003":
      return "Oops! Make sure you only request each column once.";
    case "02-004":
      return "Make sure all your columns are accompanied by a table. It looks like you have something that doesn't follow the structure: table.column .";

    # BLOCK 3: Tables, JOIN, ON
    case "03-001":
      return "Aw snap! Make sure you joined all the tables you are calling columns from.";
    case "03-002":
      return "Easy, there! Try to join each table only once. Double check you didn't join a table multiple times.";
    case "03-003":
      return "Try to join only the tables you are requesting columns from.";
    case "03-004":
      return "Double check your JOIN statements. They should follow: 'JOIN table1 ON table1.column = table2.column'.";
    case "03-005":
      return "Make sure the condition of your ON statement makes sense; table1.column and table2.column should link the two tables together by sharing a piece of data.";
    case "03-006":
      return "Double check that one of your ON condition columns comes from the table you are joining (i.e. in the example \"JOIN cities ON countries.code = parks.name\" neither countries.code nor parks.name is from the table cities).";
    case "03-007":
      return "Whoops! It looks like you are using column in an 'ON' condition more than once. This probably shouldn't be the case.";
    case "03-008":
      return "FROM and JOIN statements should be followed by a table name. Check if instead you have a 'table.column' and change it to just a 'table'.";


    # BLOCK 4: WHERE, AND
    case "04-001":
      return "Make sure your WHERE meets all the criteria you need. You should have to use an \"AND\".";
    case "04-002":
      return "Whoops! You only need an \"AND\" when using a \"WHERE\" and you need to meet two criteria (i.e. WHERE <column1> = <value1> AND <column2> >= <value2>).";
    case "04-003":
      return "Make sure you are only asking for the rows you need. Think about using a \"WHERE\" statement.";
    case "04-004":
      return "If you want rows that meet multiple conditions, try using \"AND\" instead of mulitple \"WHERE\" statements.";
    case "04-005":
      return "It looks like you're using a \"WHERE\" statement. \"WHERE\" is needed when you only want the rows that meet a specific condition.";
    case "04-006":
      return "Double check your \"WHERE\" statement matches the structure \"WHERE table.column >= condition\" (e.g. WHERE nutrition.calories >= 3000).";
    case "04-007":
      return "Make certain the column of your \"WHERE\" statement is the one you need.";
    case "04-008":
      return "Confirm the logic of your \"WHERE\" statement is what you need. Check the relationship (<, >, <=, >=, =, LIKE) and the condition (3000, "%K", "pancakes").";
    case "04-009":
      return "Make sure your WHERE meets all the criteria you need. You should have to use an \"OR\".";
    case "04-010":
      return "Whoops! You only need an \"OR\" when using a \"WHERE\" and you need to meet at least one criteria (i.e. WHERE <column1> = <value1> OR <column2> >= <value2>).";

    # BLOCK 5: ORDER BY
    case "05-001":
      return "If you need to sort the results of your query, try adding the \"ORDER BY\" statement.";
    case "05-002":
      return "It looks like you have more than one \"ORDER BY\" statement. If you need to sort by multiple columns, try using the structure \"ORDER BY <column1> ASC, <column2> DESC\"";
    case "05-003":
      return "Try to use the structure \"ORDER BY <column1> ASC, <column2> DESC\"";
    case "05-004":
      return "In your \"ORDER BY\" condition, make sure you are sorting the correct column.";
    case "05-005":
      return "In your \"ORDER BY\" condition, double check that you are sorting the results in the correct order (ASC or DESC).";

  }
}
