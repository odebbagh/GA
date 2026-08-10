property persons : Collection
property _notAvailables : Collection
property _propositions : Object
property minLengthTrigram : Integer
property maxLengthTrigram : Integer

Class constructor($persons : Collection; $notAvailables : Collection)
	
	This:C1470.persons:=New collection:C1472()
	This:C1470._notAvailables:=New collection:C1472()
	This:C1470._propositions:=New object:C1471()
	This:C1470.minLengthTrigram:=3
	This:C1470.maxLengthTrigram:=4
	If (Count parameters:C259>0)
		This:C1470.setPersons($persons)
	End if 
	If (Count parameters:C259>1)
		This:C1470.setNotAvailables($notAvailables)
	End if 
	
	
	
	//HOW TO USE
	
	//var $trigram : cs.F8n_trigram
	//var $eEmployee : cs.f8n_EmployeeEntity
	
	//$trigram:=cs.F8n_trigram.new()
	//$trigram.minLengthTrigram:=3
	//$trigram.maxLengthTrigram:=4
	
	//$notAvailables:=ds.f8n_Employee.query("initials # :1"; "").toCollection("initials").extract("initials")
	//$trigram.setNotAvailables($notAvailables)
	
	//$persons:=ds.f8n_Employee.query("initials = :1 or initials = null"; "").toCollection("UUID, firstName, lastName")
	//$trigram.setPersons($persons)
	
	//$trigram.generateTrigram()
	//$persons:=$trigram.getPersons()
	
	//For each ($person; $persons)
	
	//$eEmployee:=ds.f8n_Employee.get($person.UUID)
	//$eEmployee.initials:=$person.trigram
	//$eEmployee.save()
	
	//End for each 
	
	
	
Function setPersons($persons : Collection)
	
	var $person : Object
	
	This:C1470.persons:=$persons
	For each ($person; This:C1470.persons)
		If ($person.trigram=Null:C1517)
			$person.trigram:=""
		End if 
	End for each 
	
	
	
Function getPersons()->$persons : Collection
	
	$persons:=This:C1470.persons
	
	
	
Function setNotAvailables($notAvailables : Collection)
	
	This:C1470._notAvailables:=$notAvailables.copy().distinct()
	
	
	
Function generateTrigram()
	
	var $phase : Integer
	var $initials : Collection
	var $trigram : Text
	var $person : Object
	
	For ($phase; 1; 5)
		For each ($person; This:C1470.persons.query("trigram = :1"; ""))
			$initials:=This:C1470._getInitials($phase; $person)
			$trigram:=Uppercase:C13(Substring:C12($initials.join(""); 1; This:C1470.maxLengthTrigram))
			This:C1470._pushProposition($trigram; $person)
		End for each 
		This:C1470._useProposition()
	End for 
	
	
	
Function _pushProposition($trigram : Text; $person : Object)
	
	If (Length:C16($trigram)>=This:C1470.minLengthTrigram)
		If (This:C1470._notAvailables.indexOf($trigram)=-1)
			If (This:C1470._propositions[$trigram]=Null:C1517)
				This:C1470._propositions[$trigram]:=New collection:C1472()
			End if 
			This:C1470._propositions[$trigram].push($person)
		End if 
	End if 
	
	
	
Function _useProposition
	
	var $trigram : Text
	
	For each ($trigram; This:C1470._propositions)
		If (This:C1470._propositions[$trigram].length=1)
			This:C1470._propositions[$trigram][0].trigram:=$trigram
			This:C1470._notAvailables.push($trigram)
		End if 
	End for each 
	This:C1470._propositions:=New object:C1471()
	
	
	
Function _getInitials($phase : Integer; $person : Object)->$initials : Collection
	
	var $parts : Collection
	var $part : Text
	
	$initials:=New collection:C1472()
	Case of 
		: ($phase=1)
			$parts:=This:C1470._splitInParts($person.firstName+" "+$person.lastName)
			For each ($part; $parts)
				$initials.push(Substring:C12($part; 1; 1))
			End for each 
			
		: ($phase=2)
			$parts:=This:C1470._splitInParts($person.firstName)
			$initials.push(Substring:C12($parts[0]; 1; 2))
			$parts:=This:C1470._splitInParts($person.lastName)
			$initials.push(Substring:C12($parts[0]; 1; 1))
			
		: ($phase=3)
			$parts:=This:C1470._splitInParts($person.firstName)
			$initials.push(Substring:C12($parts[0]; 1; 1))
			$parts:=This:C1470._splitInParts($person.lastName)
			$initials.push(Substring:C12($parts[0]; 1; 2))
			
		: ($phase=4)
			$parts:=This:C1470._splitInParts($person.firstName)
			$initials.push(Substring:C12($parts[0]; 1; 1))
			$parts:=This:C1470._splitInParts($person.lastName)
			$initials.push(Substring:C12($parts[0]; 1; 1)+Substring:C12($parts[0]; Length:C16($parts[0]); 1))
			
		: ($phase=5)
			$parts:=This:C1470._splitInParts($person.firstName)
			$initials.push(Substring:C12($parts[0]; 1; 1)+Substring:C12($parts[0]; Length:C16($parts[0]); 1))
			$parts:=This:C1470._splitInParts($person.lastName)
			$initials.push(Substring:C12($parts[0]; 1; 1))
			
	End case 
	
	
	
Function _splitInParts($text : Text)->$parts : Collection
	
	$text:=Replace string:C233($text; "-"; " ")
	$parts:=Split string:C1554($text; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2)