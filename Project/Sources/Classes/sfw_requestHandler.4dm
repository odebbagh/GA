
property url : Text

Class constructor($url : Text)
	ARRAY TEXT:C222($_names; 0)
	ARRAY TEXT:C222($_values; 0)
	
	$url_motifs:=Split string:C1554($url; "?"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
	This:C1470.url:=$url_motifs.shift()
	
	WEB GET VARIABLES:C683($_names; $_values)
	For ($i; 1; Size of array:C274($_names); 1)
		If (Position:C15("."; $_names{$i})#0)
			$obj_attrs:=Split string:C1554($_names{$i}; "."; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
			If (This:C1470[$obj_attrs[0]]=Null:C1517)
				This:C1470[$obj_attrs[0]]:=New object:C1471()
			End if 
			This:C1470[$obj_attrs[0]][$obj_attrs[1]]:=$_values{$i}
		Else 
			This:C1470[$_names{$i}]:=$_values{$i}
		End if 
	End for 
	
	
Function dispatch()->$result : Object
	$paths:=Storage:C1525.web_router.query("path == :1"; This:C1470.url)
	If ($paths.length=0)
		EXECUTE METHOD:C1007("home_page"; $result; This:C1470)
		
	Else 
		
		If (Bool:C1537($paths[0].restrict)) & (Session:C1714.isGuest())
			WEB SEND HTTP REDIRECT:C659("/login")
		Else 
			$method:=$paths[0].method
			EXECUTE METHOD:C1007($method; $result; This:C1470)
		End if 
	End if 
	
	
Function render($result : Object)
	If ($result#Null:C1517)
		Use (Session:C1714.storage)
			Session:C1714.storage.httpResponse:=OB Copy:C1225($result; ck shared:K85:29)
		End use 
		
		WEB SEND FILE:C619($result.view)
		
		Use (Session:C1714.storage)
			Session:C1714.storage.httpResponse:=Null:C1517
		End use 
	End if 
	