singleton Class constructor
	
	
	
Function getBestFormat($value : Real)
	
	var $collSize : Collection
	var $level : Integer
	var $unity : Text
	
	$collSize:=New collection:C1472("b"; "Kb"; "Mb"; "Gb"; "Tb")
	$level:=0
	While (($value/1024)>1)
		$level:=$level+1
		$value:=$value/1024
	End while 
	
	$unity:=$collSize[$level]
	Case of 
		: ($value=0)
			$unity:=""
			$resultat:="-"
		: ($value>100)
			$resultat:=String:C10($value; "###,##0")
		: ($value>10)
			$resultat:=String:C10($value; "#,##0.0")
		: ($value>1)
			$resultat:=String:C10($value; "#,##0.00")
		Else 
			$resultat:=String:C10($value; "#,##0.000")
	End case 
	
	GET SYSTEM FORMAT:C994(Decimal separator:K60:1; $decimalSeparator)
	
	$p:=Position:C15($decimalSeparator; $resultat)
	If ($p>0)
		$decimalPart:=Num:C11(Substring:C12($resultat; $p+1))
		If ($decimalPart=0)
			$resultat:=Substring:C12($resultat; 1; $p-1)
		End if 
	End if 
	
	If ($unity#"")
		$resultat:=$resultat+" "+$unity
	End if 
	
	$0:=$resultat
	