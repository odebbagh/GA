//%attributes = {}
// redraws the "n items" counter of the entry list (unit1 / unitN wording). sfw sets it when the
// list is searched, but not when a record is added or deleted, so after creating a second lead
// it still read "2 lead". Run in the main window through CALL FORM, once sfw has updated lb_items
If (Form:C1466#Null:C1517) && (Form:C1466.sfw#Null:C1517) && (OB Instance of:C1731(Form:C1466.sfw; cs:C1710.sfw_main))
	Form:C1466.sfw.lb_items_counter_format()
End if
