//%attributes = {"executedOnServer":true}
// _fix_badNumbersSrv($bad) -> {fixed; failed; objects}  (for _fix_badNumbers)
// On the server, where the records load: each number attribute listed by _diag_badNumbers is
// set to 0 and the record saved. Object attributes are counted, not changed.
#DECLARE($bad : Collection)->$result : Object
var $row; $attr : Object
var $e : 4D.Entity
var $save : Object
var $changed : Boolean
$result:={fixed: 0; failed: 0; objects: 0}
For each ($row; $bad)
	$e:=ds[$row.dataclass].get($row.UUID)
	If ($e=Null)
		continue
	End if
	$changed:=False
	For each ($attr; $row.attributes)
		If ($attr.type="number")
			$e[$attr.name]:=0
			$changed:=True
			$result.fixed+=1
		Else
			$result.objects+=1
		End if
	End for each
	If ($changed)
		$save:=$e.save()
		If (Not($save.success))
			$result.failed+=1
		End if
	End if
End for each
