// cs.jobDataExporter class declaration 

property filePath : Text
property fields : Collection:=New collection:C1472()
property area : Text
property jobs : Collection  //cs.JobSelection
property fileName : Text
property folderPath : Text
property autoQuit : Boolean

Class constructor($path : Text; $fields : Collection; $jobs : Collection; $fileName : Text; $folderPath : Text)
	This:C1470.filePath:=$path
	This:C1470.fields:=$fields
	This:C1470.jobs:=$jobs
	This:C1470.fileName:=$fileName
	This:C1470.autoQuit:=False:C215
	This:C1470.folderPath:=$folderPath
	
	// This function will be called on each event of the offscreen area 
Function onEvent()
	Case of 
		: (FORM Event:C1606.code=On VP Ready:K2:59)
			
			$o:=New object:C1471()
			
			$excelOptions:={includeStyles: False:C215; includeFormulas: True:C214; openMode: ""}
			$o.excelOptions:=$excelOptions
			$o.formula:=Formula:C1597(SET TIMER:C645(30))
			VP IMPORT DOCUMENT(This:C1470.area; This:C1470.filePath; $o)  // make an asynch callback
			
		: (Form event code:C388=On Timer:K2:25)
			
			SET TIMER:C645(0)
			
			$row:=3
			$col:=0
			
			For each ($job; This:C1470.jobs)
				//VP INSERT ROWS(VP Row(This.area; $row; 1))
				For each ($field; This:C1470.fields)
					Case of 
							
						: ($field="postToPO") | ($field="shipped")
							$content:=$job[$field]=False:C215 ? "N" : "Y"
							VP SET TEXT VALUE(VP Cell(This:C1470.area; $col; $row); $content)
							
						Else 
							VP SET TEXT VALUE(VP Cell(This:C1470.area; $col; $row); String:C10($job[$field]))
							
					End case 
					$col:=$col+1
				End for each 
				$row:=$row+1
				$col:=0
				VP INSERT ROWS(VP Row(This:C1470.area; $row; 1))
			End for each 
			
			$file:=Folder:C1567(Convert path system to POSIX:C1106(This:C1470.folderPath)).file(This:C1470.fileName)
			
			If (Not:C34($file.exists))
				$file.create()
			End if 
			
			var $params:={}
			$params.format:=vk MS Excel format:K89:2
			$params.formula:=Formula:C1597(ACCEPT:C269)
			$excelOptions:={includeStyles: True:C214; includeFormulas: True:C214}
			$params.excelOptions:=$excelOptions
			VP EXPORT DOCUMENT(This:C1470.area; $file.platformPath; $params)
			
			//cs.sfw_dialog.me.info(ds.sfw_readXliff("export.done"; "The export is done"))
			OPEN URL:C673($file.platformPath; *)
			
	End case 
	
	
	
	
	
	
	
	
	
	