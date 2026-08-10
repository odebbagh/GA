property data : Object
property dataFile : Text


Class constructor
	
	var $folder : 4D:C1709.Folder
	var $file : 4D:C1709.File
	
	$folder:=Folder:C1567(fk database folder:K87:14).folder("sourceControler")
	If ($folder.exists=False:C215)
		$folder.create()
	End if 
	$file:=$folder.file("data.json")
	If ($file.exists=False:C215)
		$file.create()
		$file.setText("{}"; "UTF-8")
	End if 
	This:C1470.dataFile:=$file.path
	This:C1470.data:=JSON Parse:C1218($file.getText("UTF-8"))
	
	This:C1470.getPathReferenceFolder()
	
	
	
Function getPathReferenceFolder()
	var $referenceFolderPath : Text
	
	If (This:C1470.data.referenceFolder=Null:C1517)
		This:C1470.data.referenceFolder:=New object:C1471()
		$referenceFolderPath:=Select folder:C670("Select the reference folder")
		If (ok=1)
			This:C1470.setPathReferenceFolder($referenceFolderPath)
		End if 
	End if 
	
	
	
Function setPathReferenceFolder($fullPath : Text)
	
	This:C1470.data.referenceFolder.platformPath:=$fullPath
	This:C1470.storeData()
	
Function storeData()
	
	var $file : 4D:C1709.File
	
	$file:=File:C1566(This:C1470.dataFile)
	$file.setText(JSON Stringify:C1217(This:C1470.data; *); "UTF-8")
	
	
Function fullPush()
	
	var $folderReference : 4D:C1709.Folder
	
	$folderReference:=Folder:C1567(This:C1470.data.referenceFolder.platformPath; fk platform path:K87:2).folder("reference")
	If ($folderReference.exists=False:C215)
		$folderReference.create()
	End if 
	This:C1470._pushResources($folderReference)
	This:C1470._pushSfw($folderReference)
	This:C1470._pushProject($folderReference)
	This:C1470._pushModifyTableNum($folderReference)
	This:C1470._pushDocumentation($folderReference)
	This:C1470._storeAttributes($folderReference)
	This:C1470._storeStructureDescription($folderReference)
	
	This:C1470.data.lastFullCommit:=New object:C1471
	This:C1470.data.lastFullCommit.date:=Current date:C33
	This:C1470.data.lastFullCommit.time:=Current time:C178
	This:C1470.storeData()
	
	
Function _pushResources($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folder : 4D:C1709.Folder
	var $file : 4D:C1709.File
	var $fileCopied : 4D:C1709.File
	var $folderResources : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $lprojFolder : 4D:C1709.Folder
	var $copy : Boolean
	
	$folderResources:=Folder:C1567(fk resources folder:K87:11)
	
	$targetFolder:=$folderReference.folder("Resources")
	If ($targetFolder.exists=False:C215)
		$targetFolder.create()
	End if 
	
	For each ($folder; $folderResources.folders())
		
		If ($folder.extension=".lproj")  //lproj
			$lprojFolder:=$targetFolder.folder($folder.fullName)
			If ($lprojFolder.exists=False:C215)
				$lprojFolder.create()
			End if 
			For each ($file; $folder.files())
				$copy:=True:C214
				Case of 
					: ($file.name="sfw")
					: ($file.name="sfw_@")
					: ($file.name="dfd")
					: ($file.name="dfd_@")
					Else 
						$copy:=False:C215
				End case 
				If ($copy)
					$fileCopied:=$file.copyTo($lprojFolder; fk overwrite:K87:5)
				End if 
			End for each 
		End if 
		
		If ($folder.name="sfw") || ($folder.name="dfd")
			$sfwFolder:=$folder.copyTo($targetFolder; fk overwrite:K87:5)
		End if 
		
	End for each 
	
	
Function _pushSfw($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folderResources : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $folderToCommit : 4D:C1709.Folder
	var $folderToUpdate : 4D:C1709.Folder
	var $foldersToCommit : Collection
	var $file : 4D:C1709.File
	var $fileCopied : 4D:C1709.File
	
	$folderResources:=Folder:C1567(fk resources folder:K87:11)
	
	$targetFolder:=$folderReference.folder("Resources")
	If ($targetFolder.exists=False:C215)
		$targetFolder.create()
	End if 
	
	//$file:=$folderResources.file("sfw_constants.xlf")
	//$fileCopied:=$file.copyTo($targetFolder; fk overwrite)
	
Function _pushDocumentation($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folderDocumentation : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $folderToCommit : 4D:C1709.Folder
	var $folderToUpdate : 4D:C1709.Folder
	var $foldersToCommit : Collection
	var $file : 4D:C1709.File
	var $fileCopied : 4D:C1709.File
	
	$folderDocumentation:=Folder:C1567(fk database folder:K87:14).folder("Documentation")
	
	$targetFolder:=$folderReference
	If ($targetFolder.exists=False:C215)
		$targetFolder.create()
	End if 
	
	$foldersToCommit:=New collection:C1472($folderDocumentation)
	
	While ($foldersToCommit.length>0)
		$folderToCommit:=$foldersToCommit.shift()
		$folderToUpdate:=$targetFolder.folder(Replace string:C233($folderToCommit.path; "/PACKAGE/"; ""))
		If ($folderToUpdate.exists=False:C215)
			$folderToUpdate.create()
		End if 
		$foldersToCommit:=$foldersToCommit.concat($folderToCommit.folders())
		
		For each ($file; $folderToCommit.files())
			$copy:=True:C214
			Case of 
				: ($file.name="sfw_@")
				: ($file.name="dfd_@")
				Else 
					$copy:=False:C215
			End case 
			If ($copy)
				$fileCopied:=$file.copyTo($folderToUpdate; fk overwrite:K87:5)
			End if 
		End for each 
	End while 
	
	
Function _pushProject($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folder : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $projectFolder : 4D:C1709.Folder
	var $sourceFolder : 4D:C1709.Folder
	var $folderToCommit : 4D:C1709.Folder
	var $folderToUpdate : 4D:C1709.Folder
	var $foldersToCommit : Collection
	var $copy : Boolean
	var $tableNum : Integer
	var $tableName : Text
	var $file : 4D:C1709.File
	var $fileCopied : 4D:C1709.File
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14).folder("Project")
	$sourceFolder:=$projectFolder.folder("Sources")
	
	$targetFolder:=$folderReference.folder("Project/Sources")
	If ($targetFolder.exists=False:C215)
		$targetFolder.create()
	Else 
		$targetFolder.delete(Delete with contents:K24:24)
		$targetFolder.create()
	End if 
	
	$foldersToCommit:=New collection:C1472
	$foldersToCommit.push($sourceFolder.folder("TableForms"))
	$foldersToCommit.push($sourceFolder.folder("Methods"))
	$foldersToCommit.push($sourceFolder.folder("Forms"))
	$foldersToCommit.push($sourceFolder.folder("Classes"))
	$foldersToCommit.push($sourceFolder.folder("Triggers"))
	
	While ($foldersToCommit.length>0)
		$folderToCommit:=$foldersToCommit.shift()
		$folderToUpdate:=$targetFolder.folder(Replace string:C233($folderToCommit.path; "/PACKAGE/Project/Sources/"; ""))
		
		If ($folderToUpdate.exists=False:C215)
			$folderToUpdate.create()
		End if 
		
		For each ($folder; $folderToCommit.folders())
			$copy:=True:C214
			Case of 
				: ($folder.name="sfw_@")
				: ($folder.name="dfd_@")
				: ($folder.name=String:C10(Num:C11($folder.name)))
					$tableNum:=Num:C11($folder.name)
					If (Is table number valid:C999($tableNum))
						$tableName:=Table name:C256($tableNum)
						Case of 
							: ($tableName="sfw_@")
							: ($tableName="dfd_@")
							Else 
								$copy:=False:C215
						End case 
					Else 
						$copy:=False:C215
					End if 
				: ($folder.name="ObjectMethods")
				: ($folder.name="Images")
				: ($folder.parent.name=String:C10(Num:C11($folder.parent.name)))
				Else 
					$copy:=False:C215
			End case 
			If ($copy)
				$foldersToCommit.push($folder)
			End if 
		End for each 
		
		For each ($file; $folderToCommit.files())
			$copy:=True:C214
			Case of 
				: ($file.fullName="form.4DForm")
				: ($file.fullName="method.4dm") & (String:C10($file.parent.parent.name)="Forms")
					
				: ($file.name="DataStore")
					//Todo: n'exporter que les functions de classe préfixées par sfw_
					var $classPrototype : Object:=New object:C1471
					var $functionNames : Collection
					var $originClassCode; $functionHeader; $functionCode; $functionName; $classCode : Text
					
					
					$originClassCode:=$file.getText()
					
					$classPrototype:=cs:C1710["DataStore"].__prototype
					$functionNames:=OB Keys:C1719($classPrototype)
					
					$copy:=False:C215
					$file:=$folderToUpdate.file("DataStore")
					If (Not:C34($file.exists))
						$file.create()
					End if 
					
					$codeLines:=Split string:C1554($originClassCode; "\r")
					
					$functionName:=""
					For ($i; 0; $codeLines.length-1)
						
						Case of 
							: ($codeLines[$i]="@Function @")  // ligne de déclaration d'une fonction
								
								$functionName:=Substring:C12($codeLines[$i]; Position:C15("Function "; $codeLines[$i])+9)
								$functionName:=Substring:C12($functionName; 1; Position:C15("("; $functionName)-1)
								
								If ($functionName="sfw_@") || ($functionName="_sfw_@") || ($functionName="dfd_@") || ($functionName="_dfd_@")
									$classCode+=$codeLines[$i]+"\r"
								Else 
									$functionName:="--notInteresting"
								End if 
								
							: ($functionName="--notInteresting") && ($codeLines[$i-1]="//MARK:@")
								// ligne de commentaire avec bookmark
								$classCode+=$codeLines[$i]+"\r"
								
							: ($functionName="--notInteresting")
								// on ne prend pas la ligne
								
								
							Else 
								// on recopie la ligne
								$classCode+=$codeLines[$i]+"\r"
								
						End case 
						
					End for 
					
					$file.setText($classCode)
					
					
				: ($file.name="sfw")
				: ($file.name="sfw_@")
				: ($file.name="dfd")
				: ($file.name="dfd_@")
				: ($file.parent.name="ObjectMethods")
				: ($file.parent.name="Images")
				: ($file.name="table_@") & ($file.parent.name="Triggers")
					$tableNum:=Num:C11(Replace string:C233($file.name; "table_"; ""))
					If (Is table number valid:C999($tableNum))
						$tableName:=Table name:C256($tableNum)
						Case of 
							: ($tableName="sfw_@")
							: ($tableName="dfd_@")
							Else 
								$copy:=False:C215
						End case 
					Else 
						$copy:=False:C215
					End if 
				Else 
					$copy:=False:C215
			End case 
			If ($copy)
				$fileCopied:=$file.copyTo($folderToUpdate; fk overwrite:K87:5)
			End if 
		End for each 
		
	End while 
	
	
Function _pushModifyTableNum($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folder : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $file : 4D:C1709.File
	var $tableNums : Collection
	var $tableNum : Integer
	var $codes : Object
	
	$tableNums:=New collection:C1472()
	$targetFolder:=$folderReference.folder("Project/Sources")
	For each ($folder; $targetFolder.folder("TableForms").folders())
		$tableNum:=Num:C11($folder.name)
		If (Is table number valid:C999($tableNum))
			$tableNums.push($tableNum)
		End if 
	End for each 
	
	$targetFolder:=$folderReference.folder("Project/Sources")
	For each ($file; $targetFolder.folder("Triggers").files())
		$tableNum:=Num:C11(Replace string:C233($file.name; "table_"; ""))
		If (Is table number valid:C999($tableNum))
			$tableNums.push($tableNum)
		End if 
	End for each 
	$tableNums:=$tableNums.distinct()
	$codes:=New object:C1471
	For each ($tableNum; $tableNums)
		$codes[String:C10($tableNum)]:=New object:C1471("tableName"; Table name:C256($tableNum))
	End for each 
	
	$file:=$folderReference.file("referenceTableNums.json")
	If ($file.exists=False:C215)
		$file.create()
	End if 
	$file.setText(JSON Stringify:C1217($codes; *); "UTF-8")
	
	
Function _storeAttributes($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $attributes : Object
	var $methods : Object
	var $i : Integer
	var $attributesMustBeStored : Boolean
	var $file : 4D:C1709.File
	
	$methods:=New object:C1471()
	ARRAY TEXT:C222($_method; 0)
	METHOD GET PATHS:C1163(Path project method:K72:1; $_method)
	
	For ($i; 1; Size of array:C274($_method))
		$attributesMustBeStored:=True:C214
		Case of 
			: ($_method{$i}="sfw_@")
			: ($_method{$i}="dfd_@")
			Else 
				$attributesMustBeStored:=False:C215
		End case 
		If ($attributesMustBeStored)
			METHOD GET ATTRIBUTES:C1334($_method{$i}; $attributes)
			$methods[$_method{$i}]:=$attributes
		End if 
	End for 
	
	$file:=$folderReference.file("projectMethodAttibutes.json")
	If ($file.exists=False:C215)
		$file.create()
	End if 
	$file.setText(JSON Stringify:C1217($methods; *); "UTF-8")
	
	
Function _storeStructureDescription($folderReference : 4D:C1709.Folder)
	
	var $structure : Object
	var $dataclassName : Text
	var $dataclassMustBeStored : Boolean
	var $fieldName : Text
	var $file : 4D:C1709.File
	
	$structure:=New object:C1471()
	
	For each ($dataclassName; ds:C1482)
		$dataclassMustBeStored:=True:C214
		Case of 
			: ($dataclassName="sfw_@")
			: ($dataclassName="dfd_@")
			Else 
				$dataclassMustBeStored:=False:C215
		End case 
		If ($dataclassMustBeStored)
			$structure[$dataclassName]:=New object:C1471
			$structure[$dataclassName].tableName:=$dataclassName
			$structure[$dataclassName].fields:=New object:C1471()
			For each ($fieldName; ds:C1482[$dataclassName])
				$structure[$dataclassName].fields[$fieldName]:=ds:C1482[$dataclassName][$fieldName]
			End for each 
		End if 
	End for each 
	
	
	$file:=$folderReference.file("structure.json")
	If ($file.exists=False:C215)
		$file.create()
	End if 
	$file.setText(JSON Stringify:C1217($structure; *); "UTF-8")
	
	
	
Function fullPull()
	
	var $folderReference : 4D:C1709.Folder
	
	$folderReference:=Folder:C1567(This:C1470.data.referenceFolder.platformPath; fk platform path:K87:2).folder("reference")
	If ($folderReference.exists)
		
		This:C1470._pullResources($folderReference)
		This:C1470._pullSfw($folderReference)
		This:C1470._pullProject($folderReference)
		This:C1470._pullDocumentation($folderReference)
		This:C1470._restoreAttributes($folderReference)
		
		This:C1470.data.lastFullpull:=New object:C1471
		This:C1470.data.lastFullpull.date:=Current date:C33
		This:C1470.data.lastFullpull.time:=Current time:C178
		This:C1470.storeData()
		
	End if 
	
	
Function _pullResources($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folder : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $lprojFolder : 4D:C1709.Folder
	var $file : 4D:C1709.File
	var $fileCopied : 4D:C1709.File
	var $copy : Boolean
	//$folderResources:=Folder(fk resources folder)
	
	$targetFolder:=Folder:C1567(fk resources folder:K87:11)
	If ($targetFolder.exists=False:C215)
		$targetFolder.create()
	End if 
	
	For each ($folder; $folderReference.folder("Resources").folders())
		If ($folder.extension=".lproj")  //lproj
			$lprojFolder:=$targetFolder.folder($folder.fullName)
			If ($lprojFolder.exists=False:C215)
				$lprojFolder.create()
			End if 
			For each ($file; $folder.files())
				$copy:=True:C214
				Case of 
					: ($file.name="sfw_@")
					: ($file.name="dfd_@")
					Else 
						$copy:=False:C215
				End case 
				If ($copy)
					$fileCopied:=$file.copyTo($lprojFolder; fk overwrite:K87:5)
				End if 
			End for each 
		End if 
		
		If ($folder.name="sfw") || ($folder.name="dfd")
			$sfwFolder:=$targetFolder.folder($folder.fullName)
			If ($sfwFolder.exists=False:C215)
				$sfwFolder.create()
			End if 
			For each ($subFolder; $folder.folders())
				If ($subFolder.name="image")
					$imageFolder:=$subFolder.copyTo($sfwFolder; fk overwrite:K87:5)
				End if 
			End for each 
		End if 
		
	End for each 
	
	
Function _pullSfw($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folderResources : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $folderToPull : 4D:C1709.Folder
	var $folderToUpdate : 4D:C1709.Folder
	var $foldersToPull : Collection
	var $file : 4D:C1709.File
	var $fileCopied : 4D:C1709.File
	
	$folderResources:=$folderReference.folder("Resources")
	
	$targetFolder:=Folder:C1567(fk resources folder:K87:11)
	If ($targetFolder.exists=False:C215)
		$targetFolder.create()
	End if 
	
	//$file:=$folderResources.file("sfw_constants.xlf")
	//$fileCopied:=$file.copyTo($targetFolder; fk overwrite)
	
	
Function _pullDocumentation($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folderDocumentation : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $folderToPull : 4D:C1709.Folder
	var $folderToUpdate : 4D:C1709.Folder
	var $foldersToPull : Collection
	var $file : 4D:C1709.File
	var $fileCopied : 4D:C1709.File
	
	$folderDocumentation:=$folderReference
	
	$targetFolder:=Folder:C1567(fk database folder:K87:14)
	If ($targetFolder.exists=False:C215)
		$targetFolder.create()
	End if 
	
	$foldersToPull:=New collection:C1472($folderDocumentation.folder("Documentation"))
	
	While ($foldersToPull.length>0)
		$folderToPull:=$foldersToPull.shift()
		$folderToUpdate:=$targetFolder.folder(Replace string:C233($folderToPull.path; $folderDocumentation.path; ""))
		If ($folderToUpdate.exists=False:C215)
			$folderToUpdate.create()
		End if 
		$foldersToPull:=$foldersToPull.concat($folderToPull.folders())
		
		For each ($file; $folderToPull.files())
			$fileCopied:=$file.copyTo($folderToUpdate; fk overwrite:K87:5)
		End for each 
	End while 
	
	
	
Function _pullProject($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	var $folder : 4D:C1709.Folder
	var $projectFolder : 4D:C1709.Folder
	var $sourceFolder : 4D:C1709.Folder
	var $targetFolder : 4D:C1709.Folder
	var $folderToPull : 4D:C1709.Folder
	var $folderToUpdate : 4D:C1709.Folder
	var $foldersToPull : Collection
	var $file : 4D:C1709.File
	var $fileCopied : 4D:C1709.File
	var $codes : Object
	var $code : Text
	var $tableNum : Integer
	var $tableName : Text
	var $newTableNum : Integer
	var $copy : Boolean
	
	$file:=$folderReference.file("referenceTableNums.json")
	$codes:=JSON Parse:C1218($file.getText("UTF-8"))
	For each ($code; $codes)
		$tableName:=$codes[$code].tableName
		$tableNum:=0
		For ($t; 1; Last table number:C254)
			If (Is table number valid:C999($t))
				If ($tableName=Table name:C256($t))
					$tableNum:=$t
				End if 
			End if 
		End for 
		If ($tableNum>0)
			$codes[$code].newTableNum:=$tableNum
		End if 
	End for each 
	
	$projectFolder:=$folderReference.folder("Project")
	$sourceFolder:=$projectFolder.folder("Sources")
	
	$targetFolder:=Folder:C1567(fk database folder:K87:14).folder("Project/Sources")
	If ($targetFolder.exists=False:C215)
		$targetFolder.create()
	End if 
	
	$foldersToPull:=New collection:C1472
	$foldersToPull.push($sourceFolder.folder("TableForms"))
	$foldersToPull.push($sourceFolder.folder("Triggers"))
	$foldersToPull.push($sourceFolder.folder("Methods"))
	$foldersToPull.push($sourceFolder.folder("Forms"))
	$foldersToPull.push($sourceFolder.folder("Classes"))
	
	While ($foldersToPull.length>0)
		$folderToPull:=$foldersToPull.shift()
		$folderToUpdate:=$targetFolder.folder(Replace string:C233($folderToPull.path; $sourceFolder.path; ""))
		If ($folderToUpdate.exists=False:C215)
			$folderToUpdate.create()
		End if 
		
		If ($folderToUpdate.parent.name="TableForms")
			$tableNum:=Num:C11($folderToUpdate.name)
			$newTableNum:=Num:C11($codes[String:C10($tableNum)].newTableNum)
			If ($tableNum#$newTableNum)
				$folderToUpdate:=$folderToUpdate.moveTo($folderToUpdate.parent; String:C10($newTableNum))
			End if 
		End if 
		
		For each ($folder; $folderToPull.folders())
			$copy:=True:C214
			Case of 
				: ($folder.name="sfw_@")
				: ($folder.name="dfd_@")
				: ($folder.name=String:C10(Num:C11($folder.name)))
					$tableNum:=Num:C11($folder.name)
					If ($codes[String:C10($tableNum)]#Null:C1517)
						$newTableNum:=Num:C11($codes[String:C10($tableNum)].newTableNum)
						If (Is table number valid:C999($newTableNum))
							$tableName:=Table name:C256($newTableNum)
							Case of 
								: ($tableName="sfw_@")
								: ($tableName="dfd_@")
								Else 
									$copy:=False:C215
							End case 
						Else 
							$copy:=False:C215
						End if 
					End if 
				: ($folder.name="ObjectMethods")
				: ($folder.name="Images")
				: ($folder.parent.name=String:C10(Num:C11($folder.parent.name)))
				Else 
					$copy:=False:C215
			End case 
			If ($copy)
				$foldersToPull.push($folder)
			End if 
		End for each 
		
		For each ($file; $folderToPull.files())
			$copy:=True:C214
			Case of 
				: ($file.fullName="sfw_sourceControler.4dm")
					//$copy:=False  //il ne faut pas modifier la class qui s'éxécute !
				: ($file.fullName="form.4DForm")
				: ($file.fullName="method.4dm") & (String:C10($file.parent.parent.name)="Forms")
				: ($file.name="DataStore")
				: ($file.name="sfw")
				: ($file.name="sfw_@")
				: ($file.name="dfd")
				: ($file.name="dfd_@")
				: ($file.parent.name="ObjectMethods")
				: ($file.parent.name="Images")
				: ($file.name="table_@") & ($file.parent.name="Triggers")
					$tableNum:=Num:C11(Replace string:C233($file.name; "table_"; ""))
					If ($codes[String:C10($tableNum)]#Null:C1517)
						$newTableNum:=Num:C11($codes[String:C10($tableNum)].newTableNum)
						If (Is table number valid:C999($newTableNum))
							$tableName:=Table name:C256($newTableNum)
							Case of 
								: ($tableName="sfw_@")
								: ($tableName="dfd_@")
								Else 
									$copy:=False:C215
							End case 
						Else 
							$copy:=False:C215
						End if 
					Else 
						$copy:=False:C215
					End if 
				Else 
					$copy:=False:C215
			End case 
			If ($copy)
				If (($file.name="table_@") & ($file.parent.name="Triggers"))
					$tableNum:=Num:C11(Replace string:C233($file.name; "table_"; ""))
					$newTableNum:=Num:C11($codes[String:C10($tableNum)].newTableNum)
					$fileCopied:=$file.copyTo($folderToUpdate; "table_"+String:C10($newTableNum); fk overwrite:K87:5)
				Else 
					$fileCopied:=$file.copyTo($folderToUpdate; fk overwrite:K87:5)
				End if 
			End if 
		End for each 
	End while 
	
	
Function _restoreAttributes($folderReference : 4D:C1709.Folder; $date : Date; $time : Time)
	
	//var $currentAttributes : Object
	//var $newAttributes : Object
	//var $file : 4D.File
	//var $methods : Object
	//var $method : Text
	//var $update : Boolean
	
	//$file:=$folderReference.file("projectMethodAttibutes.json")
	//$methods:=JSON Parse($file.getText("UTF-8"))
	
	//ARRAY TEXT($_method; 0)
	//METHOD GET PATHS(Path project method; $_method)
	
	//For each ($method; $methods)
	//$newAttributes:=$methods[$method]
	//If (Find in array($_method; $method)>0)
	//METHOD GET ATTRIBUTES($method; $currentAttributes)
	//$newAttributes:=$methods[$method]
	//$update:=(JSON Stringify($currentAttributes)#JSON Stringify($newAttributes))
	//Else 
	//$update:=True
	//End if 
	//If ($update)
	//METHOD SET ATTRIBUTES($method; $newAttributes)
	//End if 
	//End for each 
	
	
	
Function export()
	var $sourceControler : cs:C1710.sfw_sourceControler
	
	$ok:=cs:C1710.sfw_dialog.me.confirm(ds:C1482.sfw_readXliff("export.sfw"; "Do you want to export all the source for the framework ?"))
	If ($ok)
		$sourceControler:=cs:C1710.sfw_sourceControler.new()
		$sourceControler.fullPush()
		SHOW ON DISK:C922($sourceControler.data.referenceFolder.platformPath)
	End if 
	
Function import()
	var $sourceControler : cs:C1710.sfw_sourceControler
	
	$ok:=cs:C1710.sfw_dialog.me.confirm(ds:C1482.sfw_readXliff("import.sfw"; "Do you want to import all the source for the framework ?"))
	If ($ok)
		$sourceControler:=cs:C1710.sfw_sourceControler.new()
		
		$sourceControler.fullPull()
		
		cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("import.sfwDone"; "Full Import is done ! I wish you a good work with this new version of the framework."))
	End if 