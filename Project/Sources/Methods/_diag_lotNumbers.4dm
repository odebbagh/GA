//%attributes = {}
// _diag_lotNumbers
// Read only: the Lot counter (Table sequence number) and the 15 lots with the highest numbers,
// to find which lots took a number the counter did not give. Changes nothing. Writes
// Project/imports/lot_numbers.txt, copies the same text to the clipboard and shows a summary.
var $counter; $highest : Integer
var $lot : 4D:C1709.Entity
var $lines : Collection
var $text; $parent; $job; $customer : Text
var $file : 4D:C1709.File
	
$counter:=Get database parameter:C643([Lot:118]; Table sequence number:K37:31)
$highest:=Num:C11(ds:C1482.Lot.all().max("number"))
$lines:=New collection:C1472
$lines.push("LOT NUMBERS - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178))
$lines.push("Lot counter: "+String:C10($counter)+" | highest number in use: "+String:C10($highest)+" | lots: "+String:C10(ds:C1482.Lot.all().length))
$lines.push("")
$lines.push("number | Lot # shown | lotNumber | sub | parent | date in | device | job | customer")
For each ($lot; ds:C1482.Lot.all().orderBy("number desc").slice(0; 15))
	$parent:="-"
	If ($lot.lotParent#Null:C1517)
		$parent:=String:C10($lot.lotParent.number)
	End if 
	$job:="-"
	$customer:="-"
	If ($lot.job#Null:C1517)
		$job:=String:C10($lot.job.jobNumber)
		$customer:=String:C10($lot.job.customerName)
	End if 
	$lines.push(String:C10($lot.number)+" | "+$lot.displayNumber+" | "+String:C10($lot.lotNumber)+" | "+String:C10($lot.subSequence)+" | "+$parent+" | "+String:C10($lot.dateIn)+" | "+String:C10($lot.device)+" | "+$job+" | "+$customer)
End for each 
$text:=$lines.join(Char:C90(Carriage return:K15:38))
$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("lot_numbers.txt")
$file.setText($text)
SET TEXT TO PASTEBOARD:C523($text)
ALERT:C41("Lot counter "+String:C10($counter)+", highest lot number "+String:C10($highest)+".\rThe full list is in Project/imports/lot_numbers.txt and on the clipboard: paste it to Claude.")
