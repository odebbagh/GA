Class extends DataClass

Function sequence()->$sequence : Integer
	$es:=This:C1470.all().orderBy("number desc")
	If ($es.length#0)
		$sequence:=$es[0].number+1
	Else 
		$sequence:=1
	End if 
	
	