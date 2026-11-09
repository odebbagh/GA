//%attributes = {"executedOnServer":true}
// __import_quote_param -> report lines
// Replaces the quote statuses and revisions with QuoteStatus_export.json and Revision_export.json
// from the data folder's DataJson. A table whose file is missing is left as it is.
// Report: Project/imports/quote_param_import.txt. Run it before __import_data_quote.
#DECLARE()->$lines : Collection

$lines:=_import_paramTables(New collection:C1472(\
New object:C1471("table"; ->[QuoteStatus:133]; "dataclass"; "QuoteStatus"; "file"; "QuoteStatus_export.json"; "idField"; "statusID"); \
New object:C1471("table"; ->[Revision:60]; "dataclass"; "Revision"; "file"; "Revision_export.json"; "idField"; "levelID")\
); "quote_param_import.txt")
