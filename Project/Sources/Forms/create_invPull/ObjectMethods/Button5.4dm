Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		$menu:=""
		
		$staff_es:=ds:C1482.Staff.all().orderBy("fullName asc")
		
		For each ($staff_e; $staff_es)
			$menu:=$menu+$staff_e.fullName+";"
		End for each 
		
		Form:C1466.invPull.pulledBy:=Pop up menu:C542($menu)
End case 