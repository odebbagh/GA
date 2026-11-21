//%attributes = {"executedOnServer":true}
// _import_glAccountsLinkSrv($byGlac) -> report text  (for _import_glAccounts)
// On the server: links each buy line and each buy order to its GL account by the legacy GLAC
// text ($byGlac: glac -> GLAccount UUID).
//   BuyingOrderLine.glAccount   the legacy GLAC of the line
//   BuyingOrder.moreData.glac   the legacy GLAC of the order (accountNumber is a lossy number)
// A record is saved only when its link changes. Run here, not on a 4D Remote client: the
// records do not travel, and a record the client could not load (_diag_badNumbers) is fine.
#DECLARE($byGlac : Object)->$report : Text

var $line : cs.BuyingOrderLineEntity
var $order : cs.BuyingOrderEntity
var $glac : Text
var $linked; $already; $unmatched; $noValue; $failed : Integer
var $save : Object

If (ds.BuyingOrderLine["UUID_GLAccount"]=Null)
	$report:="\r\rBuyingOrderLine.UUID_GLAccount does not exist yet, so no buy line was linked."
Else
	For each ($line; ds.BuyingOrderLine.query("glAccount # :1"; ""))
		$glac:=String($line.glAccount)
		If ($byGlac[$glac]=Null)
			$unmatched+=1
			continue
		End if
		If ($line.UUID_GLAccount=$byGlac[$glac])
			$already+=1
			continue
		End if
		$line.UUID_GLAccount:=$byGlac[$glac]
		$save:=$line.save()
		If ($save.success)
			$linked+=1
		Else
			$failed+=1
		End if
	End for each
	$report:="\rBuy lines linked: "+String($linked)+" | already linked: "+String($already)+" | GL account not found: "+String($unmatched)+\
		(($failed=0) ? "" : " | could not be saved: "+String($failed))
End if

$linked:=0
$already:=0
$unmatched:=0
$failed:=0
If (ds.BuyingOrder["UUID_GLAccount"]=Null)
	$report+="\r\rBuyingOrder.UUID_GLAccount does not exist yet, so no buy order was linked."
Else
	For each ($order; ds.BuyingOrder.all())
		$glac:=($order.moreData=Null) ? "" : String($order.moreData.glac)
		Case of
			: ($glac="")
				$noValue+=1
			: ($byGlac[$glac]=Null)
				$unmatched+=1
			: ($order.UUID_GLAccount=$byGlac[$glac])
				$already+=1
			Else
				$order.UUID_GLAccount:=$byGlac[$glac]
				$save:=$order.save()
				If ($save.success)
					$linked+=1
				Else
					$failed+=1
				End if
		End case
	End for each
	$report+="\rBuy orders linked: "+String($linked)+" | already linked: "+String($already)+" | GL account not found: "+String($unmatched)+\
		" | no GL account on the order: "+String($noValue)+(($failed=0) ? "" : " | could not be saved: "+String($failed))
End if
