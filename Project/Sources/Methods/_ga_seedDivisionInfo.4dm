//%attributes = {}

/*
Method Name : _ga_seedDivisionInfo
Purpose     : Creates (or updates) the single DivisionInfo record for GAC.

There is one division. Legacy held this in [Housekeeping_div_add], which was never
exported, so DivisionInfo has been empty - which is why the buy order's Bill to printed
blank and its Ship to had to be hardcoded.

The three addresses are the same street for GAC, and each is stored the way the address
subform shows it: the phone sits on the second line, with city / state / postcode left
empty rather than split out.

  site    -> the buy order's SHIP TO (legacy SiteAdd1 / SiteAdd2 / Telmesg)
  billing -> the buy order print's BILL TO (legacy BillingAddress1 / 2)
  remit   -> remit-to (legacy Remit_add1 / 2)

Safe to re-run: it updates the existing GAC record rather than adding another.
*/

var $division : cs:C1710.DivisionEntity
var $info : cs:C1710.DivisionInfoEntity
var $result : Object
var $type : Text
var $address : Object
var $wasNew : Boolean
var $divisionWasNew : Boolean

//---the division itself. There is one, GAC, so it is created rather than demanded:
//   refusing here just left DivisionInfo empty and the ship-to blank.
$division:=ds.Division.query("name = :1 or code = :1"; "GAC").first()

If ($division=Null)
	$division:=ds.Division.new()
	$division.name:="GAC"
	$division.code:="GAC"
	$result:=$division.save()
	If (Not($result.success))
		cs.sfw_dialog.me.alert("Could not create the GAC division."+Char(Carriage return)+String($result.statusText))
		return
	End if
	$divisionWasNew:=True
End if

$info:=ds.DivisionInfo.query("UUID_Division = :1"; $division.UUID).first()
$wasNew:=($info=Null)
If ($wasNew)
	$info:=ds.DivisionInfo.new()
	$info.UUID_Division:=$division.UUID
End if

$info.site:="GAC"
$info.parent:=True

//---the division's sales tax rate, legacy [Housekeeping_div_add]SalesTaxFraction.
//   A fraction, not a percentage: 0.1025 is 10.25%. GetDefaultSalesTax handed this to
//   [BUY_ORDERS]ST_rate, and callers multiplied by 100 only for display.
//   It goes in moreData rather than a new column - one configuration value.
$info.moreData:=($info.moreData=Null) ? New object() : $info.moreData
$info.moreData.salesTaxFraction:=0.1025

$info.contactDetails:=New object()
$info.contactDetails.addresses:=New collection()

For each ($type; New collection("site"; "billing"; "remit"))
	$address:=New object()
	$address.type:=$type
	$address.detail:=New object()
	$address.detail.street_1:="44061 Old Warm Springs Blvd"
	$address.detail.street_2:="Fremont, CA  94538, Tel: (408) 956-1010"
	$address.detail.city:=""
	$address.detail.state:=""
	$address.detail.postcode:=""
	$address.detail.country:="US"
	$address.detail.iso_code_2:="US"
	$info.contactDetails.addresses.push($address)
End for each

$result:=$info.save()

If ($result.success)
	cs.sfw_dialog.me.info(($divisionWasNew ? "Created the GAC division and its info record." : (($wasNew ? "Created" : "Updated")+" the DivisionInfo record for GAC."))\
		+Char(Carriage return)+Char(Carriage return)\
		+"44061 Old Warm Springs Blvd"+Char(Carriage return)\
		+"Fremont, CA  94538, Tel: (408) 956-1010"+Char(Carriage return)+Char(Carriage return)\
		+"New buy orders now take their Ship to from here.")
Else
	cs.sfw_dialog.me.alert("Could not save the DivisionInfo record."+Char(Carriage return)+String($result.statusText))
End if