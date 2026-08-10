//%attributes = {}
#DECLARE($nameNorm : Text)->$match : Boolean

$match:=False:C215

If ($nameNorm="")
	return $match
End if 

If ($nameNorm="qsr") | ($nameNorm="qa signoff is required") | ($nameNorm="qasignoffreqd") | (Position:C15("qa signoff"; $nameNorm)>0)
	$match:=True:C214
End if 

return $match
