#
# Loden Henning
# GROK Lab 2018
#
# This script checks the user's input for CREATE, DROP, and ALTER (DDL) commands.
#

BEGIN {
	# Ignores letter cases (e.g. A == a is true)
    IGNORECASE = 1;
}

{is_DDL = 0;}

{if ($0 ~ /drop/ || $0 ~ /alter/ || $0 ~ /create/){is_DDL = 1;}}

{print is_DDL;}

END {}
