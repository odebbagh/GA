Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("dfdTemplate"; "documentManagement"; "Templates"; "Template")
	$entry.setDataclass("dfd_Template")
	$entry.setDisplayOrder(200)
	$entry.setIcon("dfd/image/entry/dfd_Template-50x50.png")
	
	$entry.setSearchboxField("name")
	
	
	$entry.setPanel("dfd_panel_template"; 1)
	$entry.setPanelPage(1; ""; ds:C1482.sfw_readXliff("dfdTemplate.page.definition"))
	$entry.setPanelPage(2; ""; ds:C1482.sfw_readXliff("dfdTemplate.page.permissions"))
	$entry.setPanelPage(3; ""; ds:C1482.sfw_readXliff("dfdTemplate.page.docgeneration"))
	
	
	$entry.setLBItemsColumn("name"; "Name"; "xliff:documentFolder.form.name")
	
	$entry.setLBItemsOrderBy("name")
	
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:template"; "unitN:templates")
	$entry.setMainViewLabel("All templates")
	
	$entry.enableTransaction()
	
	//$entry.setItemListPreconfigAction("exportReferenceRecords")
	//$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListAction("Import a template"; "importTemplate")
	$entry.setItemListAction("Export a template"; "exportTemplate")
	
	
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")
	
	$entry.setAllowedProfiles(cs:C1710.sfw_globalParameters.me.dfd.entryTemplate.allowedProfiles || "admin")
	//$entry.setAllowedProfilesForCreation(cs.sfw_globalParameters.me.dfd.entryTemplate.allowedProfilesForCreation || "admin")
	//$entry.setAllowedProfilesForDeletion(cs.sfw_globalParameters.me.dfd.entryTemplate.allowedProfilesForDeletion || "admin")
	//$entry.setAllowedProfilesForModification(cs.sfw_globalParameters.me.dfd.entryTemplate.allowedProfilesForModification || "admin")
	
	$entry.setItemListProjection("Projection to documents"; "projectionToDocuments"; "dfdDocument"; "documentManagement")
	$entry.setItemListProjection("Projection to lines"; "projectionToLines"; "dfdLine"; "documentManagement")
	
	
Function importTemplate()
	
	$fileName:=Select document:C905(""; "json"; Localized string:C991("template.import.promptMenu"); 0)
	If (ok=1)
		$file:=File:C1566(document; fk platform path:K87:2)
		If ($file.exists)
			$json:=JSON Parse:C1218($file.getText())
			If (ok=1)
				$template:=ds:C1482.dfd_Template._importTemplate($json)
			End if 
			
			ALERT:C41(Localized string:C991("template.import.completed"))
			Form:C1466.sfw.searchBox_cross()
			
		End if 
		
	End if 
	
Function _importTemplate($json : Object)->$template : cs:C1710.dfd_TemplateEntity
	
	var $base64Picture : Text
	var $blobPicture : Blob
	var $created : Boolean
	var $filePicture : 4D:C1709.File
	var $picture : Object
	var $pictures : Collection
	var $pictureSetContent : Boolean
	var $pictureEs : cs:C1710.dfd_PictureSelection
	var $pictureE : cs:C1710.dfd_PictureEntity
	var $template_lines : cs:C1710.dfd_LineSelection
	var $image : Picture
	var $info : Object
	
	If ($json.template_lines#Null:C1517)
		
		$template_lines:=ds:C1482.dfd_Line.fromCollection($json.template_lines)
		$template:=ds:C1482.dfd_Template.get($json.template.UUID)
		If ($template=Null:C1517)
			$template:=ds:C1482.dfd_Template.new()
			$created:=True:C214
		End if 
		$template.fromObject($json.template)
		$template.save()
		
		$pictures:=$json.pictures
		For each ($picture; $pictures)
			If (Bool:C1537($picture.record))
				$pictureName:=$picture.name
				$pictureEs:=ds:C1482.dfd_Picture.query("name = :1"; $pictureName)
				If ($pictureEs.length=0)
					$pictureE:=ds:C1482.dfd_Picture.new()
					$pictureE.name:=$pictureName
				Else 
					$pictureE:=$pictureEs.first()
				End if 
				$base64Picture:=$picture.picture
				BASE64 DECODE:C896($base64Picture; $blobPicture)
				BLOB TO PICTURE:C682($blobPicture; $image)
				$pictureE.picture:=$image
				$info:=$pictureE.save()
			Else 
				
				$folder:=Folder:C1567("/PACKAGE")
				If (Folder:C1567($folder.platformPath; fk platform path:K87:2).parent.name="Components")
					$componentFolder:=Folder:C1567($folder.platformPath; fk platform path:K87:2).parent
					$databaseFolder:=$componentFolder.parent
				Else 
					$databaseFolder:=Folder:C1567($folder.platformPath; fk platform path:K87:2)
				End if 
				$pathParts:=Split string:C1554($picture.path; "/"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
				$path:=$databaseFolder.platformPath+$pathParts.join(Folder separator:K24:12)
				$filePicture:=File:C1566($path; fk platform path:K87:2)
				//$filePicture:=File($picture.path)
				//ALERT($filePicture.platformPath)
				$pictureSetContent:=True:C214
				If ($filePicture.exists)
					CONFIRM:C162(Replace string:C233(Localized string:C991("template.import.prompt"); "##1"; $filePicture.fullName))
					If (ok=0)
						$pictureSetContent:=False:C215
					End if 
				End if 
				If ($pictureSetContent)
					$base64Picture:=$picture.picture
					BASE64 DECODE:C896($base64Picture; $blobPicture)
					$filePicture.setContent($blobPicture)
				End if 
			End if 
		End for each 
	End if 
	
	
Function exportTemplate()
	
	If (Form:C1466.current_item#Null:C1517)
		$documentName:=Select document:C905(Folder:C1567(fk desktop folder:K87:19).platformPath+"template_"+Form:C1466.current_item.name+".json"; "json"; Localized string:C991("template.export.prompt"); File name entry:K24:17)
		If (ok=1)
			$file:=File:C1566(document; fk platform path:K87:2)
			
			var $template : Object
			$template:=ds:C1482.dfd_Template._export_template(Form:C1466.current_item)
			
			
			If (Not:C34($file.exists))
				$file.create()
			End if 
			If ($file.exists)
				$file.setText(JSON Stringify:C1217($template; *))
			End if 
			
			SHOW ON DISK:C922($file.platformPath)
		End if 
		
	End if 
	
Function _export_template($templateEntity : Object)->$template : Object
	
	var $blobPicture : Blob
	var $encodedPicture : Text
	var $filePicture : 4D:C1709.File
	var $line : Object
	var $linesUUID : Collection
	var $object : Object
	var $picture : Object
	var $pictures : Collection
	var $pictureEs : cs:C1710.dfd_PictureSelection
	var $template_lines : cs:C1710.dfd_LineSelection
	var $image : Picture
	
	$fieldsNames:=New collection:C1472
	For each ($attributeName; ds:C1482.dfd_Template)
		If (ds:C1482.dfd_Template[$attributeName].kind="storage")
			$fieldsNames.push($attributeName)
		End if 
	End for each 
	$template:=New object:C1471("template"; $templateEntity.toObject($fieldsNames))
	//MARK:   ••lines
	If ($templateEntity.hierarchy#Null:C1517) && ($templateEntity.hierarchy.lines#Null:C1517)
		$linesUUID:=$templateEntity.hierarchy.lines.distinct("UUID_entity")
		$template_lines:=ds:C1482.dfd_Line.query("UUID IN :1"; $linesUUID)
		If ($template_lines.length>0)
			$fieldsNames:=New collection:C1472
			For each ($attributeName; ds:C1482.dfd_Line)
				If (ds:C1482.dfd_Line[$attributeName].kind="storage")
					$fieldsNames.push($attributeName)
				End if 
			End for each 
			$template.template_lines:=$template_lines.toCollection($fieldsNames)
		End if 
	End if 
	
	//MARK:   ••pictures
	$pictures:=New collection:C1472
	For each ($line; $template.template_lines)
		For each ($object; $line.objectsForm.objects)
			If ($object.properties.type="picture")
				If ($object.properties.picture="picture(@)")
					$pictureName:=Substring:C12($object.properties.picture; 9; Length:C16($object.properties.picture)-9)
					$pictureEs:=ds:C1482.dfd_Picture.query("name = :1"; $pictureName)
					If ($pictureEs.length=1)
						$image:=$pictureEs.first().picture
						PICTURE TO BLOB:C692($image; $blobPicture; ".png")
						BASE64 ENCODE:C895($blobPicture; $encodedPicture)
						$picture:=New object:C1471()
						$picture.picture:=$encodedPicture
						$picture.name:=$pictureName
						$picture.record:=True:C214
						$pictures.push($picture)
					End if 
				Else 
					$filePicture:=File:C1566($object.properties.picture)
					If ($filePicture.exists)
						$picture:=New object:C1471()
						$picture.path:=$object.properties.picture
						$blobPicture:=$filePicture.getContent()
						BASE64 ENCODE:C895($blobPicture; $encodedPicture)
						$picture.picture:=$encodedPicture
						$picture.name:=$object.name
						$pictures.push($picture)
					End if 
				End if 
			End if 
		End for each 
	End for each 
	$template.pictures:=$pictures
	
	
	