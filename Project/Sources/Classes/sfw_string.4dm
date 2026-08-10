shared singleton Class constructor
	
	
	
Function stringCapitalize($text : Text)->$result : Text
	$lettres:="abcdefghijklmnopqrstuvwxyz"
	$majuscules:=Uppercase:C13($lettres)
	
	$particules:=Split string:C1554("O';De;Le;La;Mc;Mac;Dos;de ;du ;des ;d';de la ;de La ;von ;vom ;van ;van der ;"; ";")
	$particuleToAdd:=""
	For each ($particule; $particules)
		If ($text=($particule+"@"))
			$nextletter:=Substring:C12($text; Length:C16($particule)+1; 1)
			If (Position:C15($nextletter; $majuscules; *)>0) || (Substring:C12($particule; Length:C16($particule); 1)=" ")
				$particuleToAdd:=$particule
				$text:=Substring:C12($text; Length:C16($particule)+1)
				break
			End if 
		End if 
	End for each 
	$text:=Lowercase:C14($text; *)
	$result:=""
	$capitalize:=True:C214
	For ($i; 1; Length:C16($text))
		$car:=$text[[$i]]
		If (Position:C15($car; $lettres)>0)
			If ($capitalize)
				$capitalize:=False:C215
				$car:=Uppercase:C13($car; *)
			End if 
		Else 
			$capitalize:=True:C214
		End if 
		$result:=$result+$car
	End for 
	$result:=$particuleToAdd+$result
	
Function isAnEmptyUUID($uuid : Text)->$isEmpty : Boolean
	
	$isEmpty:=True:C214
	Case of 
		: ($uuid=Null:C1517)
		: ($uuid="")
		: (Length:C16($uuid)#32)
		: ($uuid=("0"*32))
		: ($uuid=("20"*16))
		Else 
			$isEmpty:=False:C215
	End case 
	
	
Function trimSpace($stringToTrim : Text)->$stringTrimmed : Text
	
	$stringTrimmed:=Split string:C1554($stringToTrim; " ").join(" "; ck ignore null or empty:K85:5)
	
	