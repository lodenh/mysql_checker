BEGIN {IGNORECASE = 1}

{print "\n----LINE " NR "----"}

{for(n = 1; n <= NF; n++){
  {if ($n ~ /select/) {print "SELECT:\t$" n}}
  }}

{for(n = 1; n <= NF; n++){
  {if ($n ~ /from/) {print "FROM:\t$" n}}
  }}

{for(n = 1; n <= NF; n++){
  {if ($n ~ /join/) {print "JOIN:\t$" n}}
  }}

END {}
