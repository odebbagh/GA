//%attributes = {}
#DECLARE($inputFieldParam : Variant; $state : Text)

Case of 
	: (Value type:C1509($inputFieldParam)=Is text:K8:3)
		$inputFields:=New collection:C1472($inputFieldParam)
	: (Value type:C1509($inputFieldParam)=Is collection:K8:32)
		$inputFields:=$inputFieldParam
End case 

Case of 
	: ($state="visible")
		$backgroud:=Background color none:K23:10
		$border:=Border None:K42:27
	: ($state="modify")
		$backgroud:=Background color:K23:2
		$border:=Border System:K42:33
	: ($state="error")
		$backgroud:=Background color:K23:2
		$border:=0x00FAA9AB
	Else 
		$backgroud:=Background color none:K23:10
		$border:=Border None:K42:27
End case 

For each ($inputField; $inputFields)
	OBJECT SET RGB COLORS:C628(*; $inputField; "black"; $backgroud)
	OBJECT SET BORDER STYLE:C1262(*; $inputField; $border)
End for each 