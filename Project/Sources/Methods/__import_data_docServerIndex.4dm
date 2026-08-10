//%attributes = {}


//var $eDocument : cs.DocumentEntity  //Create Document Table first and uncomment this line
var $foreignKey; $1 : Text
var $documents; $2 : Collection
var $blob : Blob

$foreignKey:=$1
$documents:=$2

For each ($document; $documents)
	
	$eDocument:=ds:C1482.Document.new()
	
	$eDocument.tableNumber:=$3
	$eDocument.foreignKey:=$foreignKey
	
	$eDocument.code:=$document.DocCode
	$eDocument.dateTimeStamp:=$document.DateTimeStamp
	$eDocument.creationDateTimeStamp:=$document.CreationDateTimeStamp
	$eDocument.documentPath:=$document.DocumentPath
	$eDocument.sourcePath:=$document.SourcePath
	$eDocument.tempCounter:=$document.TempCounter
	$eDocument.rawText:=$document.RawText
	$eDocument.description:=$document.DocDescription
	
	$report:=Folder:C1567(fk data folder:K87:12).file("DataJson/EquipmentReports/"+String:C10($document.UniqueID))
	If ($report.exists)
		
		DOCUMENT TO BLOB:C525($report.platformPath; $blob)
		
		$eDocument.blob:=$blob
		
	End if 
	
	$res:=$eDocument.save()
	If (Not:C34($res.success))
		TRACE:C157
	End if 
	
End for each 



