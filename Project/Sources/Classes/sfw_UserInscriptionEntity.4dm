Class extends Entity


local Function get since()->$since : Text
	
	$since:=String:C10(cs:C1710.sfw_stmp.me.getDate(This:C1470.stmp_given); System date short:K1:1)+" - "+String:C10(cs:C1710.sfw_stmp.me.getTime(This:C1470.stmp_given); HH MM:K7:2)