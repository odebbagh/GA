//%attributes = {}
// _import_priceListDate
// A date of the price list file (_import_priceList, ga_pricing): ISO "2026-11-01" (a time after it
// is ignored) read without depending on the system date format, which Date("2026-11-01") does.
// Any other text: read as a date in the system format. Empty or unreadable: !00-00-00!.
#DECLARE($text : Text)->$date : Date

var $parts : Collection

$text:=cs:C1710.sfw_string.me.trimSpace($text)
If ($text="")
	return
End if
$parts:=Split string:C1554(Substring:C12($text; 1; 10); "-")
If ($parts.length=3) && (Length:C16($parts[0])=4)
	If (Num:C11($parts[0])>0) && (Num:C11($parts[1])>=1) && (Num:C11($parts[1])<=12) && (Num:C11($parts[2])>=1) && (Num:C11($parts[2])<=31)
		$date:=Add to date:C393(!00-00-00!; Num:C11($parts[0]); Num:C11($parts[1]); Num:C11($parts[2]))
	End if
Else
	$date:=Date:C102($text)
End if
