#
# Loden Henning
# GROK Lab 2018
#
# Checks for required command (e.g. SELECT, SHOW, UPDATE, etc.) and associated syntax.
# Commands are: SELECT ... FROM, SHOW, USE, INSERT, UPDATE, DELETE, CREATE as "select", "show", "use", "insert", "update", "delete", "create" respectively.
#

function block1(debug_mode, result_b1, command, FROM_tables, tables_detected){

  #-----------------------------------------------------------------------------------------------------------------
  # Count how many of each command there are to determine whether student has too many, too few, or has misplaced the command.
  #

  fld_SELECT = 0;
  fld_FROM = 0;
  fld_SHOW = 0;
  fld_USE = 0;

  SELECTs_detected = 0;
  FROMs_detected = 0;
  SHOWs_detected = 0;
  USEs_detected = 0;
  INSERTs_detected = 0;
  UPDATEs_detected = 0;
  DELETEs_detected = 0;
  CREATEs_detected = 0;

  # Errors that can be made:
  SELECT_misplaced = 0;
  SHOW_misplaced = 0;
  USE_misplaced = 0;
  INSERT_misplaced = 0;
  UPDATE_misplaced = 0;
  DELETE_misplaced = 0;
  CREATE_misplaced = 0;

  {for (n = 1; n <= NF; n++){
    {if ($n == "select"){
      SELECTs_detected++;
      fld_SELECT = n;
      {if (n != 1){
        SELECT_misplaced++;
        {if (debug_mode == 1){print "\tSELECT_misplaced"}}
        result_b1[0]++;
      }}
    }}
    {if ($n == "from"){
      FROMs_detected++;
      fld_FROM = n;
    }}
    {if ($n == "show"){
      SHOWs_detected++;
      fld_SHOW = n;
      {if (n != 1){
        SHOW_misplaced++;
        {if (debug_mode == 1){print "\tSHOW_missplaced"}}
        result_b1[0]++;
      }}
    }}
    {if ($n == "use"){
      USEs_detected++;
      fld_USE = n;
      {if (n != 1){
        USE_misplaced++;
        {if (debug_mode == 1){print "\tUSE_missplaced"}}
        result_b1[0]++;
      }}
    }}
    {if ($n == "insert"){
      INSERTs_detected++;
			fld_INSERT = n;
      {if (n != 1){
        INSERT_misplaced++;
        {if (debug_mode == 1){print "\tINSERT_missplaced"}}
        result_b1[0]++;
      }}
    }}
    {if ($n == "update"){
      UPDATEs_detected++;
			fld_UPDATE = n;
      {if (n != 1){
        UPDATE_misplaced++;
        {if (debug_mode == 1){print "\tUPDATE_missplaced"}}
        result_b1[0]++;
      }}
    }}
    {if ($n == "delete"){
      DELETEs_detected++;
			fld_DELETE = n;
      {if (n != 1){
        DELETE_misplaced++;
        {if (debug_mode == 1){print "\tDELETE_missplaced"}}
        result_b1[0]++;
      }}
    }}
    {if ($n == "create"){
      CREATEs_detected++;
			fld_CREATE = n;
      {if (n != 1){
        CREATE_misplaced++;
        {if (debug_mode == 1){print "\tCREATE_missplaced"}}
        result_b1[0]++;
      }}
    }}
  }}

  # If FROM is not found, fld_FROM is set to first field that is not SELECT or field containing "." (table.column)
  {if (fld_FROM == 0){
    {for (n = 1; n <= NF; n++){
      {if ($n != "select" && $n !~ /\./){
        fld_FROM = n;
        break;
      }}
    }}
  }}

  # Print tips
  {if (command[0] == "select"){
    {if (SELECTs_detected < 1){print tip("01-001")}}
    {if (SELECTs_detected == 1 && SELECT_misplaced > 0){print tip("01-002")}}
    {if (SELECTs_detected > 1){print tip("01-003")}}
    {if (FROMs_detected < 1){print tip("01-005")}}
    {if (FROMs_detected > 1){print tip("01-006")}}
  }}
  {if (command[0] != "select"){
    {if (SELECTs_detected > 0 && FROMs_detected > 0){print tip("01-004")}
    else {
      {if (SELECTs_detected > 0){print tip("01-008")}}
    }}
  }}

	{if (command[0] != "select" && command[0] != "delete"){
		{if (FROMs_detected > 0){print tip("01-007")}}
	}}

  {if (command[0] == "show"){
    {if (SHOWs_detected < 1){print tip("01-009")}}
    {if (SHOWs_detected == 1 && SHOW_misplaced > 0){print tip("01-010")}}
    {if (SHOWs_detected > 1){print tip("01-011")}}
  }}
  {if (command[0] != "show" && SHOWs_detected > 0){print tip("01-012")}}

  {if (command[0] == "use"){
    {if (USEs_detected < 1){print tip("01-013")}}
    {if (USEs_detected == 1 && USE_misplaced > 0){print tip("01-014")}}
    {if (USEs_detected > 1){print tip("01-015")}}
  }}
  {if (command[0] != "use" && USEs_detected > 0){print tip("01-016")}}

  {if (command[0] == "insert"){
    {if (INSERTs_detected < 1){print tip("01-017")}}
    {if (INSERTs_detected == 1 && INSERT_misplaced > 0){print tip("01-018")}}
    {if (INSERTs_detected > 1){print tip("01-019")}}
  }}
  {if (command[0] != "insert" && INSERTs_detected > 0){print tip("01-020")}}

  {if (command[0] == "update"){
    {if (UPDATEs_detected < 1){print tip("01-021")}}
    {if (UPDATEs_detected == 1 && UPDATE_misplaced > 0){print tip("01-022")}}
    {if (UPDATEs_detected > 1){print tip("01-023")}}
  }}
  {if (command[0] != "update" && UPDATEs_detected > 0){print tip("01-024")}}

  {if (command[0] == "delete"){
    {if (DELETEs_detected < 1){print tip("01-025")}}
    {if (DELETEs_detected == 1 && DELETE_misplaced > 0){print tip("01-026")}}
    {if (DELETEs_detected > 1){print tip("01-027")}}
  }}
  {if (command[0] != "delete" && DELETEs_detected > 0){print tip("01-028")}}

  {if (command[0] == "create"){
    {if (CREATEs_detected < 1){print tip("01-029")}}
    {if (CREATEs_detected == 1 && CREATE_misplaced > 0){print tip("01-030")}}
    {if (CREATEs_detected > 1){print tip("01-031")}}
  }}
  {if (command[0] != "create" && CREATEs_detected > 0){print tip("01-032")}}

  # Package variables for return
  {result_b1[1] = fld_SELECT;}
  {result_b1[2] = fld_FROM;}

  #-----------------------------------------------------------------------------------------------------------------
  # Check for correct syntax surround commands
  #
  switch (command[0]){
    case "select":

      # Errors that can be made:
      DISTINCT_missing = 0;
      FROM_no_table = 0;

      # If needed, checks if the field after SELECT is "DISTINCT".
      {if (SELECTs_detected == 1){
        {if (command[1] == "distinct"){
          {if ($(fld_SELECT + 1) != "distinct"){
            DISTINCT_missing++;
            {if (debug_mode == 1){print "\tDISTINCT_missing"}}
            result_b1[0]++;
          }}
        }}
      }}

      # Checks if the field after FROM is a required table.
      table_found = 0;
      {if (FROMs_detected == 1){
        {for (i in FROM_tables){
          {if ($(fld_FROM + 1) ~ FROM_tables[i]){table_found++}}
        }}
        {if (table_found == 0){
          FROM_no_table++;
          {if (debug_mode == 1){print "\tFROM_no_table: " $(fld_FROM) " " $(fld_FROM + 1);}}
          result_b1[0]++;
        }}
      }}

      # Print tips
      {if (DISTINCT_missing > 0){print tip("01-033")}}
      {if (FROM_no_table > 0){print tip("01-034")}}

      break;

    case "show":

  		# Errors that can be made:
      SHOW_no_table_database = 0;

      # Checks that SHOW is followed by either "tables" or "databases" depending on the correct answer.
      {if (SHOWs_detected == 1){
        {if ($(fld_SHOW + 1) !~ command[1]){
          SHOW_no_table_database++;
          {if (debug_mode == 1){print "\tSHOW_no_table_database: " $(fld_SHOW) " " $(fld_SHOW + 1);}}
          result_b1[0]++;
        }}
      }}

      # Print tips
      {if (SHOW_no_table_database > 0){print tip("01-035")}}

      break;

    case "use":

      # Errors that can be made:
      USE_no_database = 0;

			# Checks that USE is followed by the database defined in command[1].
      {if (USEs_detected == 1){
        {if ($(fld_USE + 1) !~ command[1]){
          USE_no_database++;
          {if (debug_mode == 1){print "\tUSE_no_database: " $(fld_USE) " " $(fld_USE + 1);}}
          result_b1[0]++;
        }}
      }}

      # Print tips
      {if (USE_no_database > 0){print tip("01-036")}}

      break;

		case "insert":

			# Errors that can be made:
			INSERT_no_INTO = 0;
			INSERT_no_table = 0;

			# Checks that INSERT is followed by INTO.
			{if (INSERTs_detected == 1){
				{if ($(fld_INSERT + 1) != "into"){
					INSERT_no_INTO++;
					{if (debug_mode == 1){print "\tINSERT_no_INTO: " $(fld_INSERT) " " $(fld_INSERT + 1);}}
          result_b1[0]++;
				}}
			}}

			# Checks that INTO is followed by the table defined in command[1].
			{if (INSERT_no_INTO == 0){
				{if ($(fld_INSERT + 2) !~ command[1]){
					INSERT_no_table++;
					{if (debug_mode == 1){print "\tINSERT_no_table: " $(fld_INSERT) " " $(fld_INSERT + 1) " " $(fld_INSERT + 2);}}
          result_b1[0]++;
				}}
			}}

			# Print tips
			{if (INSERT_no_INTO > 0){print tip("01-037")}}
			{if (INSERT_no_table > 0){print tip("01-038")}}

			break;

		case "update":

			# Errors that can be made:
			UPDATE_no_table = 0;
			UPDATE_no_SET = 0;

			# Checks that UPDATE is followed by the table defined in command[1].
			{if (UPDATEs_detected == 1){
				{if ($(fld_UPDATE + 1) != command[1]){
					UPDATE_no_table++;
					{if (debug_mode == 1){print "\tUPDATE_no_table: " $(fld_UPDATE) " " $(fld_UPDATE + 1);}}
          result_b1[0]++;
				}}
			}}

			# Checks that UPDATE <table> is followed by SET.
			{if (UPDATE_no_table == 0){
				{if ($(fld_UPDATE + 2) != "set"){
					UPDATE_no_SET++;
					{if (debug_mode == 1){print "\tUPDATE_no_SET: " $(fld_UPDATE) " " $(fld_UPDATE + 1) " " $(fld_UPDATE + 2);}}
          result_b1[0]++;
				}}
			}}

			# Print tips
			{if (UPDATE_no_table > 0){print tip("01-039")}}
			{if (UPDATE_no_SET > 0){print tip("01-040")}}

			break;

		case "delete":

			# Errors that can be made:
			DELETE_no_FROM = 0;
			DELETE_no_table = 0;

			# Checks that DELETE is followed by FROM.
			{if (DELETEs_detected == 1){
				{if ($(fld_DELETE + 1) != "from"){
					DELETE_no_FROM++;
					{if (debug_mode == 1){print "\tDELETE_no_FROM: " $(fld_DELETE) " " $(fld_DELETE + 1);}}
          result_b1[0]++;
				}}
			}}

			# Checks that DELETE FROM is followed by the table defined in command[1].
			{if (DELETE_no_FROM == 0){
				{if ($(fld_DELETE + 2) !~ command[1]){
					DELETE_no_table++;
					{if (debug_mode == 1){print "\tDELETE_no_table: " $(fld_DELETE) " " $(fld_DELETE + 1) " " $(fld_DELETE + 2);}}
          result_b1[0]++;
				}}
			}}

			# Print tips
			{if (DELETE_no_FROM > 0){print tip("01-041")}}
			{if (DELETE_no_table > 0){print tip("01-042")}}

			break;

		case "create":

			# Errors that can be made:
			CREATE_no_type = 0;
			CREATE_no_name = 0;

			# Checks that CREATE is followed by either DATABASE or TABLE as defined in command[1].
			{if (CREATEs_detected == 1){
				{if ($(fld_CREATE + 1) != command[1]){
					CREATE_no_type++;
					{if (debug_mode == 1){print "\tCREATE_no_type: " $(fld_CREATE) " " $(fld_CREATE + 1);}}
          result_b1[0]++;
				}}
			}}

			# Checks that CREATE DATABASE|TABLE is followed by the name defined in command[2].
			{if (CREATE_no_type == 0){
				{if ($(fld_CREATE + 2) !~ command[2]){
					CREATE_no_name++;
					{if (debug_mode == 1){print "\tCREATE_no_name: " $(fld_CREATE) " " $(fld_CREATE + 1) " " $(fld_CREATE + 2);}}
          result_b1[0]++;
				}}
			}}

			# Print tips
			{if (CREATE_no_type > 0){print tip("01-043")}}
			{if (CREATE_no_name > 0){print tip("01-044")}}

			break;

    default:
      {if (debug_mode == 1){print "\tBad key variable 'command[0]'. '" command[0] "' is not supported.";}}
      result_b1[0]++;
      break;
	}

} # End of Block 1
