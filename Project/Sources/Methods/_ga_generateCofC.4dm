//%attributes = {}
/*
_ga_generateCofC

Author : Medard /4D PS
Date :15-October-2025
Purpose : Generate certificate of compliance
*/


//If (Form.current_item#Null)


var $context : Object

$context:=New object:C1471()

$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/COfCTemplate.4wp")
$template:=WP Import document:C1318($file.platformPath)

$currentItem:=ds:C1482.Lot.query("lotNumber =:1"; "200021").first()
$context.user:=Current machine:C483
$context.lot:=$currentItem  //Form.current_item

$images:=WP Get elements:C1550($template; wk type image:K81:192)
$lotStep:=$currentItem.steps.query("type =:1"; 999)
If ($lotStep.length#1) | (($currentItem.dateOut#!00-00-00!) & ($currentItem.readyToShipDate#!00-00-00!))
	WP DELETE PICTURE:C1701($images[0])
End if 

$context.lotStep:=$lotStep
$shippingAddress:=$currentItem.job.address.shipping
$address:=$shippingAddress.street+"\n"+$shippingAddress.city+"\n"+$shippingAddress.state+" "+$shippingAddress.zipCode+"\n"+$shippingAddress.country

$context.address:=$currentItem.job.dropShipCustomer+"\n"+$address

var $pictureVar : Picture
var $filePath : Text
Case of 
		
	: ($currentItem.status=1)
		$filePath:=Get 4D folder:C485(Current resources folder:K5:16)+"picts_GA"+Folder separator:K24:12+"QAStampAccept"+$currentItem.cOfCInspector+".jpeg"
	: ($currentItem.status=2)
		$filePath:=Get 4D folder:C485(Current resources folder:K5:16)+"picts_GA"+Folder separator:K24:12+"QAStampReject"+$currentItem.cOfCInspector+".jpeg"
	Else 
		
End case 

READ PICTURE FILE:C678($filePath; $pictureVar)
TRANSFORM PICTURE:C988($pictureVar; Scale:K61:2; 0.8; 0.8)
$context.stamp:=$pictureVar

If ($currentItem.status>0) | ($currentItem.location="Completed") | ($currentItem.dateOut=!00-00-00!)
	$filePath:=Get 4D folder:C485(Current resources folder:K5:16)+"picts_GA"+Folder separator:K24:12+"QASignature"+$currentItem.cOfCInspector+".jpeg"
	
	READ PICTURE FILE:C678($filePath; $pictureVar)
	TRANSFORM PICTURE:C988($pictureVar; Scale:K61:2; 0.5; 0.5)
	$context.signature:=$pictureVar
End if 

SET PRINT OPTION:C733(Orientation option:K47:2; 1)


WP SET DATA CONTEXT:C1786($template; $context)

PRINT SETTINGS:C106(2)

//WP COMPUTE FORMULAS($template)
WP PRINT:C1343($template)  //; wk do not recompute expressions)

//Else 
//cs.sfw_dialog.me.info(ds.sfw_readXliff("Info"; "No items in the list to print"))

//End if 