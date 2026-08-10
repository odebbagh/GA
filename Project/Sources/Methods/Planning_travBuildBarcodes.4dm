//%attributes = {}
#DECLARE($lot : 4D:C1709.Entity)->$barcodes : Object

var $barcodePicture : Picture
var $lotBarcodeData : Text
var $lotNumber : Text
var $parameters : Object
var $qualifier : Text
var $job : cs:C1710.JobEntity

var $jobBarcodeData : Text

var $jobNumber : Text

var $lotNumber : Text

var $parameters : Object

var $qualifier : Text

var $travellerBarcodeData : Text

var $travellerLabel : Text



$barcodes:=New object:C1471(\

"jobBarcodePic"; ""; "jobBarcodeLabel"; ""; \

"travellerBarcodePic"; ""; "travellerBarcodeLabel"; "")



If ($lot=Null:C1517)

	return $barcodes

End if 



$lotNumber:=String:C10($lot.lotNumber)

If ($lotNumber="")

	$lotNumber:=String:C10($lot.number)

End if 



If ($lot.moreData#Null:C1517) && ($lot.moreData.barcodeData#Null:C1517)

	$travellerBarcodeData:=String:C10($lot.moreData.barcodeData)

Else 

	$travellerBarcodeData:=String:C10($lot.number)

End if 



If ($lot.UUID_Job#Null:C1517) && (String:C10($lot.UUID_Job)#"")

	$job:=ds:C1482.Job.get($lot.UUID_Job)

	If ($job#Null:C1517)

		$jobNumber:=String:C10($job.jobNumber)

		If ($job.moreData#Null:C1517) && ($job.moreData.barcodeData#Null:C1517) && (String:C10($job.moreData.barcodeData)#"")

			$jobBarcodeData:=String:C10($job.moreData.barcodeData)

		Else 

			$jobBarcodeData:=$jobNumber

		End if 

		If ($jobBarcodeData#"")

			$barcodes.jobBarcodeLabel:=Planning_travSanitizeText("ErpJobNumber:"+$jobNumber)

			$parameters:=New object:C1471("data"; $jobBarcodeData; "text"; "")

			$barcodePicture:=_ga_generateBarCode($parameters)

			$barcodePicture:=Planning_travScaleBarcode($barcodePicture; 325; 26)

			$barcodes.jobBarcodePic:=Planning_travPicToBase64($barcodePicture)

		End if 

	End if 

End if 



If ($travellerBarcodeData#"")

	$travellerLabel:="Lot Traveler No:"+String:C10($lot.number)

	$qualifier:=String:C10($lot.prQualifier)

	If ($qualifier#"")

		$travellerLabel:=$travellerLabel+" ["+$qualifier+"]"

	End if 

	$barcodes.travellerBarcodeLabel:=Planning_travSanitizeText($travellerLabel)

	$parameters:=New object:C1471("data"; $travellerBarcodeData; "text"; "")

	$barcodePicture:=_ga_generateBarCode($parameters)

	$barcodePicture:=Planning_travScaleBarcode($barcodePicture; 325; 26)