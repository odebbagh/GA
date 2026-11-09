//%attributes = {}
// _diag_buyLineJson
// READ-ONLY. Finds the buy lines (BuyingOrderLine) that a Remote client cannot load:
// ds.BuyingOrderLine.all() fails there with "JSON mal-formé ... ',' found" (seen in
// _import_glAccounts). The check runs on the server (_diag_buyLineJsonSrv), which writes
// Project/imports/buyLineJson_diag.txt. Nothing is saved.

var $result : Object

$result:=_diag_buyLineJsonSrv()

cs:C1710.sfw_dialog.me.alert("Buy lines checked: "+String:C10($result.checked)+\
	"\rWith a problem: "+String:C10($result.bad)+\
	"\rBy field: "+JSON Stringify:C1217($result.byField)+\
	"\r\rReport (on the server): "+String:C10($result.path))
