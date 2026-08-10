//%attributes = {}
// Returns True when the lot step requires QA signoff.
#DECLARE($lotStep : 4D:C1709.Entity)->$required : Boolean

var $qsr : Collection
var $it : Object
var $nameNorm : Text
var $props : Object

$required:=False:C215

If ($lotStep=Null:C1517)
	return $required
End if 

$props:=$lotStep.properties

// Primary check: step property code QSR on LotStep.properties.items (same pattern as OCR in LotStep.4dm).
If ($props#Null:C1517) && ($props.items#Null:C1517)
	$qsr:=$props.items.query("name = :1"; "QSR")
	If ($qsr.length>0) && (Bool:C1537($qsr[0].enabled))
		$required:=True:C214
		return $required
	End if 
End if 

// Legacy import fallbacks.
If ($props#Null:C1517) && ($props.enabledLegacyPropertyRules#Null:C1517)
	For each ($it; $props.enabledLegacyPropertyRules)
		$nameNorm:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace(String:C10($it)))
		If (LotStep_isQASignoffName($nameNorm))
			$required:=True:C214
			return $required
		End if 
	End for each 
End if 

If ($props#Null:C1517) && ($props.legacyPropertyMask#Null:C1517)
	If ((Num:C11($props.legacyPropertyMask) & 32)=32)
		$required:=True:C214
	End if 
End if 

return $required
