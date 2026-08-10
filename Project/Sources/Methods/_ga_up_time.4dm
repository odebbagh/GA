//%attributes = {}
// $1 from
// $2 to
//$3 down time
$todays_hrs:=0
$yester_hrs:=0
Case of 
	: ($1=Current date:C33(*))
		$todays_hrs:=Round:C94(Current time:C178/3600; 0)
		$yester_hrs:=24*($2-$1)
	Else 
		$yester_hrs:=24*(($2-$1)+1)
End case 
$temp:=$yester_hrs+$todays_hrs
Case of 
	: ($3=0)
		$0:=100
	Else 
		$0:=100-(($3/$temp)*100)
End case 