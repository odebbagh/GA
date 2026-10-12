//%attributes = {}
// _fix_snStepLists
// Lots serialized before the SNA / SNF rule (ga_serialization) carry their serial-number list on
// every step. This puts each serialized lot right: the steps marked SNA or SNF keep what they
// recorded and get the lot's active units; every other step loses its list. A step open
// somewhere else (locked) is skipped and counted: run it again once it is free. Safe to rerun.
#DECLARE()->$result : Object
var $lot : cs:C1710.LotEntity
	
$result:=New object:C1471("lots"; 0; "lockedSteps"; 0)
For each ($lot; ds:C1482.Lot.query("serialization = :1"; True:C214))
	$result.lockedSteps:=$result.lockedSteps+cs:C1710.ga_serialization.me.syncAllSteps($lot)
	$result.lots:=$result.lots+1
End for each 
ALERT:C41(String:C10($result.lots)+" serialized lot(s) checked, "+String:C10($result.lockedSteps)+" step(s) locked and skipped.")
