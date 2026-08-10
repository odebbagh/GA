//%attributes = {}

Use (Storage:C1525)
	Storage:C1525.web_router:=New shared collection:C1527()
End use 

ARRAY TEXT:C222($_webMethods; 0)
METHOD GET PATHS:C1163(Path project method:K72:1; $_webMethods)
For ($i; 1; Size of array:C274($_webMethods))
	If ($_webMethods{$i}#Current method name:C684)
		METHOD GET CODE:C1190($_webMethods{$i}; $code)
		$lines:=Split string:C1554($code; "\r"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
		
		$stop:=False:C215
		For each ($line; $lines) Until ($stop)
			If ($line="@#Path@")
				$stop:=True:C214
				$jsonPath:=Replace string:C233($line; "//#Path"; "")
				$path:=JSON Parse:C1218($jsonPath)
				$path.method:=$_webMethods{$i}
				Use (Storage:C1525.web_router)
					Storage:C1525.web_router.push(OB Copy:C1225($path; ck shared:K85:29))
				End use 
			End if 
		End for each 
		
	End if 
End for 

