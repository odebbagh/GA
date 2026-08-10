//%attributes = {}
// 1 = date in
// 2 = timein
// 3 = date out
// 4 = time out
$4:=$4+0
$2:=$2+0
Case of 
	: (ok=-1)
		Case of 
			: (($3>$1) | ($3<$1))  //DATEIN > or < DATEOUT
				$hrs:=((?24:00:00?-$2)+$4)\3600  // get hours
				$mins:=(((?24:00:00?-$2)+$4)\60)%60
				$mins:=$mins/60  // in decimal
				$hrs:=$hrs+(24*(($3-$1)-1))
			: ($3=$1)
				If (($4-$2)<0)
					$Hrs:=-(($2-$4)\3600)
					$mins:=-((($2-$4)\60)%60)
					$mins:=$mins/60  // in decimal      
				Else 
					$Hrs:=($4-$2)\3600
					$mins:=(($4-$2)\60)%60
					$mins:=$mins/60  // in decimal
				End if 
		End case 
		
		$0:=$hrs+$mins
	Else 
		$StartDT:=_ga_setDateTimeStamp($1; $2)
		$StopDT:=_ga_setDateTimeStamp($3; $4)
		$0:=Round:C94(($StopDT-$StartDT)/3600; 4)
End case 
