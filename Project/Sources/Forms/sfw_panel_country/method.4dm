var $nil : Pointer
var $width : Integer
var $height : Integer
var $column : Integer
var $line : Integer

sfw_panel_formMethod

$evt:=FORM Event:C1606.code
If ($evt=On Load:K2:1)
	FORM GOTO PAGE:C247(1; *)
	
	//creation of the matrice for the address format
	For ($column; 1; 4; 1)
		For ($line; 1; 7; 1)
			If ($column#1) | ($line#1)
				$newName:="address_L"+String:C10($line)+"C"+String:C10($column)
				OBJECT DUPLICATE:C1111(*; "address_L1C1"; $newName; $nil; ""; 110*($column-1); 28*($line-1))
				OBJECT SET TITLE:C194(*; $newName; $newName)
			End if 
		End for 
	End for 
	
End if 

If ($evt=On Load:K2:1) | ($evt=On Bound Variable Change:K2:52)
	
	sfw_country_tmpt_address
	
	
End if 

OBJECT GET SUBFORM CONTAINER SIZE:C1148($width; $height)

OBJECT GET COORDINATES:C663(*; "country_tab"; $g; $h; $d; $b)
OBJECT SET COORDINATES:C1248(*; "country_tab"; 0; $h; $width; $b)

OBJECT GET COORDINATES:C663(*; "adgeo_country_geocodage_sf"; $g; $h; $d; $b)
OBJECT SET COORDINATES:C1248(*; "adgeo_country_geocodage_sf"; $g; $h; $width-10; $height-10)
