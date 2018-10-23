#
# Loden Henning
# GROK Lab 2018
#
# This is a collection of custom functions needed for answer checker scripts
#

# Takes array input and returns an int of the number of elements in array
function arraylength(array){
  amount = 0;
  {for (x in array){
    ++amount;
  }}
  return amount;
}


# Takes array input and returns index of last element
function last_element(array){
  amount = -1;
  {for (x in array){
    ++amount;
  }}
  return amount;
}
