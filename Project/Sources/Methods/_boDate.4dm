//%attributes = {}
// _boDate($date) -> Text
// PL_SetFormat(...; "7"; 2; 0) on the date columns is 4D's short date, and an empty date
// printed blank rather than 00/00/00.

#DECLARE($date : Date)->$text : Text

$text:=($date=!00-00-00!) ? "" : String:C10($date; System date short:K1:1)
