//%attributes = {}
// _ga_normKey
// Comparison key for names written differently in different sources: upper case, letters
// and digits only. "Wire Bond", "WIRE BOND" and "Wirebond" all give "WIREBOND".
// Same rule as the aliases keys in Project/imports/gaf_step_links.json.
#DECLARE($text : Text)->$key : Text
	
var $i : Integer
var $code : Integer
	
$key:=""
$text:=Uppercase:C13($text)
For ($i; 1; Length:C16($text))
	$code:=Character code:C91($text[[$i]])
	If (($code>=65) & ($code<=90)) | (($code>=48) & ($code<=57))
		$key:=$key+$text[[$i]]
	End if 
End for 
