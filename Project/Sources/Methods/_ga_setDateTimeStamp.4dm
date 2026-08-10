//%attributes = {}
// SetDateTimeStamp Project Method
// SetDateTimeStamp{ ( date ; Time ) } -> Long
// SetDateTimeStamp{ ( date ; Time ) } -> Number of seconds since Jan, 1st 2000

$datetimestampRef:=Add to date:C393(!00-00-00!; 2000; 1; 1)
C_DATE:C307($1; $vdDate)
C_TIME:C306($2; $vhTime)
C_LONGINT:C283($0; $vdDate2)
If (Count parameters:C259=0)
	$vdDate:=Current date:C33(*)
	$vhTime:=Current time:C178(*)
Else 
	$vdDate:=$1
	If (Count parameters:C259>1)
		$vhTime:=$2
	Else 
		$vhTime:=Current time:C178(*)
	End if 
End if 
If ($vdDate=!00-00-00!)
	$0:=0
Else 
	$0:=(($vdDate-$datetimestampRef)*86400)+$vhTime
End if 

