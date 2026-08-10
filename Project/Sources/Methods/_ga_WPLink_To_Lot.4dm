//%attributes = {}

var $es : cs:C1710.LotSelection
$data:=$2
$es:=ds:C1482.Lot.query("lotNumber = :1"; $data.parameter)
If ($es.length>0)
	cs:C1710.panel_equipment.me.linkOpenLot($es[0]; "customerService"; "lots")
End if 

