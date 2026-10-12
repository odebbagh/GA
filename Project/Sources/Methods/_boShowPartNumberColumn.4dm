//%attributes = {}
// _boShowPartNumberColumn -> Boolean
// Legacy AdminControlledHKOptions("ShowPartNumberNotOrderDate"), which chose between the
// two buy-order line layouts in Variable2 of Company_PO_WP:
//   True  -> Item# | Description | Part-Number | Units | Qty | Unit price | Tax | Line total | Date reqd
//   False -> Item# | Description | Units | Qty | Unit price | Tax | Line total | Order date | Date reqd
//
// DEFAULTS TO TRUE. A printed buy order from the live system (BO 30443) shows the
// Part-Number column and no Order date, so the option is on in production - even though
// the Else branch is the one Variable2 falls into when the setting is absent. Matching
// the paper matters more than matching the fallback.
//
// An [sfw_Setting] with ident "ShowPartNumberNotOrderDate" overrides it either way,
// keyed the same as sfw._getSettingVersionReferenceRecords reads its own.

#DECLARE->$show : Boolean

var $eSetting : cs:C1710.sfw_SettingEntity

$show:=True:C214

$eSetting:=ds:C1482.sfw_Setting.query("ident = :1"; "ShowPartNumberNotOrderDate").first()
If ($eSetting=Null:C1517)
	return 
End if 
If ($eSetting.data=Null:C1517)
	return 
End if 

$show:=Bool:C1537($eSetting.data.value)