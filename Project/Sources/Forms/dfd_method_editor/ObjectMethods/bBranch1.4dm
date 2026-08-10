var $start; $end : Integer
var $refMenu : Text

$thems:=New collection:C1472()

$them:=New object:C1471()
$thems.push($them)
$them.label:="autour des chaines"
$them.functions:=New collection:C1472
$them.functions.push(New object:C1471("label"; "Chaine"; "code"; "String($value)"))
$them.functions.push(New object:C1471("label"; "Sous chaine"; "code"; "Substring($value;1;5)"))
$them.functions.push(New object:C1471("label"; "Caractere"; "code"; "Char($num)"))
$them.functions.push(New object:C1471("label"; "Majuscule"; "code"; "Uppercase($string)"))
$them.functions.push(New object:C1471("label"; "Minuscule"; "code"; "Lowercase($string)"))
$them.functions.push(New object:C1471("label"; "Remplacer chaine"; "code"; "Replace string($string;$old;$new)"))
$them.functions.push(New object:C1471("label"; "Supprimer chaine"; "code"; "Delete string($string;$position;$nb)"))
$them.functions.push(New object:C1471("label"; "Inserer chaine"; "code"; "Insert string($string;$toInsert;$position)"))

$them:=New object:C1471()
$thems.push($them)
$them.label:="autour des numériques"
$them.functions:=New collection:C1472
$them.functions.push(New object:C1471("label"; "Num"; "code"; "Num($value)"))
$them.functions.push(New object:C1471("label"; "Longueur"; "code"; "Length($value)"))


$refMenus:=New collection:C1472
$refMenu:=Create menu:C408
$refMenus.push($refMenu)

For each ($them; $thems)
	$refSubMenu:=Create menu:C408
	$refMenus.push($refSubMenu)
	
	For each ($function; $them.functions)
		APPEND MENU ITEM:C411($refSubMenu; $function.label)
		SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--Function:"+$function.code)
	End for each 
	
	APPEND MENU ITEM:C411($refMenu; $them.label; $refSubMenu)
End for each 

$choose:=Dynamic pop up menu:C1006($refMenu)
For each ($refMenu; $refMenus)
	RELEASE MENU:C978($refMenu)
End for each 

$toInsert:=""
Case of 
	: ($choose="--Function:@")
		$toInsert:=Substring:C12($choose; 12)
		
End case 

If ($toInsert#"")
	GET HIGHLIGHT:C209(*; "inputMethod"; $start; $end)
	If ($start>1)
		Form:C1466.method:=Substring:C12(Form:C1466.method; 1; $start-1)+$toInsert+Substring:C12(Form:C1466.method; $end)
		HIGHLIGHT TEXT:C210(*; "inputMethod"; $start; $start+Length:C16($toInsert))
	Else 
		Form:C1466.method:=$toInsert+Form:C1466.method
	End if 
End if 
