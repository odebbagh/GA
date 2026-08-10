Class extends EntitySelection


Function projectionToDocuments()->$esDocument : cs:C1710.dfd_Document
	
	$esDocument:=This:C1470.documents
	
Function projectionToLines()->$esLine : cs:C1710.dfd_LineSelection
	var $line : cs:C1710.dfd_LineEntity
	
	$esLines:=ds:C1482.dfd_Line.newSelection()
	
	$Lines:=This:C1470.hierarchy
	For each ($e; $Lines)
		For each ($l; $e.lines)
			$line:=ds:C1482.dfd_Line.get($l.UUID_entity)  //query("UUID = :1"; $l.UUID_entity).first()
			$esLines:=$esLines.add($line)
		End for each 
	End for each 
	
	