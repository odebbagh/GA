//%attributes = {}



$bins:=ds:C1482.Bin.all().extract("inventories")

$position:=-600
$searchField:="binLocationPath"
$tableName:="Bin"
$moduleName:="customerService"
$titleField:="binLocationPath"
$entryImagePath:="bin-white-50x50.png"

$gen:=cs:C1710.Util_entryFactory.new()
$fields:=New collection:C1472()
$fields.push(New object:C1471("name"; "binLocationPath"; "label"; "Location Path"; "width"; "200"))
$fields.push(New object:C1471("name"; "isEmpty"; "label"; "Empty"; "width"; "80"))
$gen.buildEntry($tableName; $moduleName; $fields; $position; $searchField; $titleField; $entryImagePath)

// 🔄 FORCER LE RAFRAÎCHISSEMENT
RELOAD PROJECT:C1739



$record:="ASSY OSS RACK IQC B1"
$formula:=Formula:C1597(Replace string:C233(This:C1470.binLocationPath; "/"; " ")=$record)
$bin:=ds:C1482.Bin.query($formula)

$locations:=ds:C1482.Location.all().extract("name").distinct()


ds:C1482.Step.all()

$position:=-500
$searchField:="description"
$tableName:="Step"
$moduleName:="housekeeping"
$titleField:="description"
$entryImagePath:="Step-white-50x50.png"

$gen:=cs:C1710.Util_entryFactory.new()
$fields:=New collection:C1472()
$fields.push(New object:C1471("name"; "description"; "label"; "Description"; "width"; "150"))
$fields.push(New object:C1471("name"; "stepTemplate.name"; "label"; "Template Name"; "width"; "100"))
$gen.buildEntry($tableName; $moduleName; $fields; $position; $searchField; $titleField; $entryImagePath)


// 🔄 FORCER LE RAFRAÎCHISSEMENT
RELOAD PROJECT:C1739

$text:=cs:C1710.Util.me.firstLetterLowerCase("LotStep")



TRUNCATE TABLE:C1051([sfw_Notification:69])

var $buyingOrders : cs:C1710.BuyingOrderSelection
$buyingOrders:=ds:C1482.BuyingOrder.query("supplier.name =:1"; "XYZ@")
$buyingOrderLines:=New collection:C1472()
If ($buyingOrders#Null:C1517)
	For each ($buyingOrder; $buyingOrders)
		$buyingOrderLines:=$buyingOrderLines.concat($buyingOrder.boLines.toCollection())
		//For each ($buyingOrderLine; $buyingOrder.boLines)
		//$buyingOrderLines.push($buyingOrderLine)
		
		//End for each 
	End for each 
End if 
$buyingOrderLines.orderBy("orderDate")
$tags:=$buyingOrderLines.map(Formula:C1597(String:C10(Month of:C24($1.value.orderDate))+"-"+String:C10(Year of:C25($1.value.orderDate)))).distinct()
$allDates:=$buyingOrderLines.extract("orderDate")

$object:=New object:C1471()
$data:=New collection:C1472()
var $quarter : Integer

For ($i; 0; $buyingOrderLines.length-1)
	
	$year:=String:C10(Year of:C25($buyingOrderLines[$i].orderDate))
	If (OB Is defined:C1231($object; $year))
	Else 
		OB SET:C1220($object; $year; New object:C1471())
	End if 
	
	$month:=String:C10(Month of:C24($buyingOrderLines[$i].orderDate))
	$date:=$month+"-"+$year
	
	$lineItem:=$data.query("date =:1"; $date).first()
	$indinces:=$data.indices("date =:1"; $date)
	If ($indinces.length=0)  //OB Is defined($object[$year]; $month))
		
		OB SET:C1220($object[$year]; $month; New collection:C1472())
		
		$quarter:=(Num:C11($month)<=3) ? 1 : (Num:C11($month)>3 && Num:C11($month)<=6) ? 2 : (Num:C11($month)>6 && Num:C11($month)<=9) ? 3 : 4
		
		$line:=New object:C1471(\
			"date"; $date; \
			"year"; $year; \
			"month"; $month; \
			"quarter"; $quarter; \
			"receivingTotalLots"; $buyingOrderLines[$i].qty; \
			"receivingWithoutNMNs"; $buyingOrderLines[$i].qtyReceived; \
			"receivingLAR"; 0; \
			"functionalTotalLots"; $buyingOrderLines[$i].qty; \
			"functionalWithoutNMNs"; $buyingOrderLines[$i].qtyFunctional; \
			"functionalLAR"; 0; \
			"deliveryTotalLots"; 0; \
			"deliveryMinorDelay"; 0; \
			"deliveryMajorDelay"; 0; \
			"deliveryLAR"; 0; \
			"compositeOverAllRating"; 0; \
			"ISOCertified"; ""\
			)
		
		$data.push($line)
		
	Else 
		
		$lineItem.receivingTotalLots:=$lineItem.receivingTotalLots+$buyingOrderLines[$i].qty
		$lineItem.receivingWithoutNMNs:=$lineItem.receivingWithoutNMNs+$buyingOrderLines[$i].qty
		$lineItem.functionalTotalLots:=$lineItem.functionalTotalLots+$buyingOrderLines[$i].qty
		$lineItem.functionalWithoutNMNs:=$lineItem.functionalWithoutNMNs+$buyingOrderLines[$i].qtyFunctional
		
		$data.remove($indinces[0])
		
		$data.push($lineItem)
		
		
	End if 
	
End for 

//Finish Calculations
For ($i; 0; $data.length-1)
	$data[$i].receivingLAR:=($data[$i].receivingWithoutNMNs/$data[$i].receivingTotalLots)*100
	$data[$i].functionalLAR:=($data[$i].functionalWithoutNMNs/$data[$i].functionalTotalLots)*100
	
End for 



$buyItems_file:=Folder:C1567(fk data folder:K87:12).file("DataJson/buy_items_export.json")
var $text : Text:=""
If ($buyItems_file.exists)
	$buyItems:=JSON Parse:C1218($buyItems_file.getText())
	
	
	For each ($buyItem; $buyItems)
		If ($buyItem.PO_NUM=34274)
			
		End if 
		
		
	End for each 
	
End if 


$buyOrders:=ds:C1482.BuyingOrder.all()

$buyOrdersItems:=ds:C1482.BuyingOrderLine.all()


/*

$time:=Replace string(String(Time(Timestamp); System time short); ";"; "")
var $1; $data : Text  // Ex: "12345"
var $pattern; $char; $color : Text
var $i; $j; $width; $posX : Integer
var $dict : Collection:=New collection()
var $vpict : Picture

$data:="12345"  //$1
$dict:=New collection(\
"nnnWWnWnn"; \
"WnnWnnnnW"; \
"nnWWnnnnW"; \
"WnWWnnnnn"; \
"nnnWWnnnW"; \
"WnnWWnnnn"; \
"nnWWWnnnn"; \
"nnnWnnWnW"; \
"WnnWnnWnn"; \
"nnWWnnWnn"; \
"nWnWnnnnn"\
)


$fullData:=$data  //"*"+$data+"*"  // Ajout des Start/Stop
//$svg:="<svg xmlns='http://www.w3.org/2000/svg' width='100%' height='100%'>"
$svg:=DOM Create XML Ref("svg"; "http://www.w3.org/2000/svg")
DOM SET XML ATTRIBUTE($svg; "width"; "100%"; "height"; "100%")
$posX:=0

For ($i; 1; Length($fullData))
$char:=$fullData[[$i]]
$pattern:=$dict[Num($char)]

If ($pattern#Null)
For ($j; 1; 9)
// Déterminer la largeur : Large=3 unités, Étroit=1 unité
$width:=Choose($pattern[[$j]]="W"; 3; 1)

// Alternance : J impair = Noir, J pair = Blanc (on ne dessine que le noir)
If ($j%2#0)
//$svg+="<rect x='"+String($posX)+"' y='0' width='"+String($width)+"' height='50' fill='black' />"
$ref:=DOM Create XML element($svg; "rect"; "x"; String($posX); "y"; 0; "width"; String($width); "height"; "50"; "fill"; "black")
End if 

$posX:=$posX+$width
End for 
$posX:=$posX+1  // Espace inter-caractère (blanc étroit obligatoire)
End if 
End for 

//Utilisation du résultat : 
SVG EXPORT TO PICTURE($svg; $vpict; Copy XML data source)
*/

//var vpict : Picture
//$svg:=DOM Create XML Ref("svg"; "http://www.w3.org/2000/svg")
//$ref:=DOM Create XML element($svg; "text"; "font-size"; 26; "fill"; "red")
//DOM SET XML ATTRIBUTE($ref; "y"; "1em")
//DOM SET XML ELEMENT VALUE($ref; "Hello World")
//SVG EXPORT TO PICTURE($svg; $vpict; Copy XML data source)
//DOM CLOSE XML($svg)

//WRITE PICTURE FILE(""; $vpict)

//TRANSFORM PICTURE($vpict; Scale; 1; 0.99)
//$doc:=WP New()
//$range:=WP Text range($doc; wk end text; wk end text)
//WP Insert picture($range; $vpict; wk append)

//SET PRINT PREVIEW(True)

//WP PRINT($doc)

//ZINT PLUGIN TESTING

//$Zint_Params:=New object

//OB SET($Zint_Params; ZINT_FORMAT; ZINT_Format_SVG)
//OB SET($zint_params; ZINT_WHITE_SPACE; 2)


//OB SET($Zint_Params; ZINT_NO_TEXT; False)
//OB SET($zint_params; ZINT_HEIGHT; 40)
//OB SET($zint_params; ZINT_SCALE; 0.5)
//OB SET($Zint_Params; ZINT_TYPE; BARCODE_CODE39)
//OB SET($Zint_Params; ZINT_PRIMARY; "Lot: "+ds.Lot.all()[0].lotNumber)

//$bar:=ZINT(ds.Lot.all()[0].moreData.barcodeData; $Zint_Params)

//$barcode:=$bar.image
//TRANSFORM PICTURE($barcode; Scale; 1; 0.99)
//$doc:=WP New()
//$range:=WP Text range($doc; wk end text; wk end text)
//WP Insert picture($range; $barcode; wk append)

//SET PRINT PREVIEW(True)

//WP PRINT($doc)


//$po:=ds.PurchaseOrder.query("oldPoNumber =:1"; "4513841818")

//$jobs:=ds.Job.query("jobNumber =:1"; 1664)

//$poLines:=ds.CAOTypeDetail.all()
//$invoiceNum:=725
//$invoices:=ds.Invoice.all().extract("invoice").orderBy(ck ascending)
//$invoice:=ds.Invoice.query("purchaseOrder.customer.name = :1"; "ALDETEC")
////SET TEXT TO PASTEBOARD($invoices.join("\n"))



