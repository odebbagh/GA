//%attributes = {}

$pdfName:=Replace string:C233(Replace string:C233(Replace string:C233(String:C10(Timestamp:C1445); ":"; ""); "-"; ""); "."; "")+"TestOD.pdf"
$path:="C:\\Users\\omar.debbagh\\Desktop\\GA_PDFs\\"+$pdfName
$docRef:=Create document:C266($path)
CLOSE DOCUMENT:C267($docRef)

$lot:=ds:C1482.Lot.query("number = 9668")[0]

$lotBarCodePic:=_ga_generateBarCode($lot.moreData; String:C10($lot.number))
$jobBarcode:=_ga_generateBarCode($lot.job.moreData; String:C10($lot.job.jobNumber))
//$jobBarcodePic:=_ga_generateBarCode($lot.job.moreData; String($lot.job.jobNumber))

$opts:=New object:C1471("pdfPath"; $path; "printPreview"; True:C214)
$data:=New object:C1471("headerTest"; "omar debbagh"; "dynPict"; $lotBarCodePic)
//"lotBarCodePic"; $lotBarCodePic

$doc:=ds:C1482.dfd_Document.buildFromTemplate("Template Test"; "Template Test"; $data; "pdf"; $opts)

OPEN URL:C673($path)

If (False:C215)
	$pdfName:=Replace string:C233(String:C10(Timestamp:C1445); ":"; "")+"TestOD.pdf"
	$path:=System folder:C487(Desktop:K41:16)+$pdfName
	$docRef:=Create document:C266($path)
	CLOSE DOCUMENT:C267($docRef)
	
	$opts:=New object:C1471("pdfPath"; $path; "printPreview"; False:C215)
	
	//$testLines:=New collection()
	
	//$sub:=New collection()
	//$sub.push(New object("order"; 21; "description"; "test description 2-1"))
	//$sub.push(New object("order"; 22; "description"; "test description 2-2"))
	//$testLines.push(New object("order"; 2; "description"; "test description 2"; "sub"; $sub))
	
	//$testLines.push(New object("order"; 3; "description"; "test description 3"))
	
	//$lot:=ds.Lot.query("number = 9668")[0]
	
	
	
	//$sub:=New collection()
	//$sub.push(New object("order"; 41; "description"; "test description 4-1"))
	//$sub.push(New object("order"; 42; "description"; "test description 4-2"))
	//$sub.push(New object("order"; 43; "description"; "test description 4-3"))
	//$testLines.push(New object("order"; 4; "description"; "test description 4"; "sub"; $sub))
	
	//$data:=New object("order"; 1; "description"; "test description"; "testLines"; $testLines)
	
	$data:=New object:C1471("headerTest"; "omar debbagh")
	
	$doc:=ds:C1482.dfd_Document.buildFromTemplate("Template Test"; "Template Test"; $data; "pdf"; $opts)
	
	OPEN URL:C673($path)
End if 
