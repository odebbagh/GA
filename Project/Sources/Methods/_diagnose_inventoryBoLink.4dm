//%attributes = {}

// Why is Inventory.UUID_BuyingOrderLine not being set?
//
// The link is made by matching a key built on each side:
//   inventory side : stockGroupRoot from the export, e.g. "30507_1284"
//                    (legacy [Inventory]Stock_Num = PO_NUM + "_" + Seq_Number)
//   buy-line side  : String(boNumber) + "_" + String(legacySeqNum)
//
// If either side is empty or formatted differently, every lookup misses. This reports
// both sides and their overlap. Read-only, changes nothing.

var $projectFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $boLine : cs:C1710.BuyingOrderLineEntity
var $boLineByKey : Object
var $key : Text
var $report : Text
var $lineCount; $withSeq; $i; $overlap; $rootsPresent; $boStock : Integer
var $sampleLines; $sampleRoots : Collection

$report:=""

//---buy-line side
$boLineByKey:=New object:C1471()
$sampleLines:=New collection:C1472()
$lineCount:=0
$withSeq:=0

For each ($boLine; ds:C1482.BuyingOrderLine.all())
	$lineCount:=$lineCount+1
	If (Num:C11($boLine.legacySeqNum)#0)
		$withSeq:=$withSeq+1
	End if
	$key:=String:C10($boLine.boNumber)+"_"+String:C10($boLine.legacySeqNum)
	$boLineByKey[$key]:=$boLine.UUID
	If ($sampleLines.length<5)
		$sampleLines.push($key)
	End if
End for each

$report:=$report+"BUY LINES"+"\r"
$report:=$report+"  rows:                    "+String:C10($lineCount)+"\r"
$report:=$report+"  with legacySeqNum # 0:   "+String:C10($withSeq)+"\r"
$report:=$report+"  distinct keys built:     "+String:C10(OB Keys:C1719($boLineByKey).length)+"\r"
$report:=$report+"  sample keys:             "+$sampleLines.join(", ")+"\r\r"

//---inventory side, straight from the import file
$projectFolder:=Folder:C1567(fk database folder:K87:14)
$file:=$projectFolder.folder("project/imports").file("inventory_export.json")

If (Not:C34($file.exists))
	$report:=$report+"IMPORT FILE NOT FOUND:"+"\r  "+$file.platformPath
	ALERT:C41($report)
	return
End if

$records:=JSON Parse:C1218($file.getText())
$sampleRoots:=New collection:C1472()
$rootsPresent:=0
$boStock:=0
$overlap:=0

For each ($record; $records)
	If (Bool:C1537($record.isBuyOrderStock))
		$boStock:=$boStock+1
		$key:=String:C10($record.stockGroupRoot)
		If ($key#"")
			$rootsPresent:=$rootsPresent+1
			If ($boLineByKey[$key]#Null:C1517)
				$overlap:=$overlap+1
			Else
				If ($sampleRoots.length<5)
					$sampleRoots.push($key)
				End if
			End if
		End if
	End if
End for each

$report:=$report+"IMPORT FILE"+"\r"
$report:=$report+"  path:                    "+$file.platformPath+"\r"
$report:=$report+"  records:                 "+String:C10($records.length)+"\r"
$report:=$report+"  first record has keys:   "+($records.length>0 ? OB Keys:C1719($records[0]).slice(0; 4).join(", ") : "-")+"\r"
$report:=$report+"  isBuyOrderStock = true:  "+String:C10($boStock)+"\r"
$report:=$report+"  with a stockGroupRoot:   "+String:C10($rootsPresent)+"\r\r"

$report:=$report+"MATCH"+"\r"
$report:=$report+"  roots that find a line:  "+String:C10($overlap)+"\r"
$report:=$report+"  unmatched sample:        "+$sampleRoots.join(", ")+"\r\r"

//---what actually landed in the table
$report:=$report+"INVENTORY TABLE NOW"+"\r"
$report:=$report+"  rows:                    "+String:C10(ds:C1482.Inventory.all().length)+"\r"
$report:=$report+"  with stockGroup set:     "+String:C10(ds:C1482.Inventory.query("stockGroup # :1"; "").length)+"\r"
//---An unset UUID_BuyingOrderLine is the ZERO uuid, not "": the column is
//   store_as_UUID and never_null. Comparing it to "" matched every row, which is why
//   this line used to report all 14,718 as linked.
$report:=$report+"  with a buy line linked:  "+String:C10(ds:C1482.Inventory.query("UUID_BuyingOrderLine # :1"; ("0"*32)).length)

ALERT:C41($report)
