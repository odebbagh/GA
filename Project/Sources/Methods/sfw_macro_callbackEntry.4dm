//%attributes = {}
#DECLARE($method_path)
$classeName:=Substring:C12($method_path; 9)
Case of 
	: ($method_path#"[class]/@")
		cs:C1710.sfw_dialog.me.alert("You aren't in a class")
		
	: (ds:C1482[$classeName]=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("You aren't in a class who extend a dataclass")
		
	Else 
		GET MACRO PARAMETER:C997(Full method text:K5:17; $fulltext)
		GET MACRO PARAMETER:C997(Highlighted method text:K5:18; $highlighttext)
		
		
		$memberFunctions:=OB Keys:C1719(cs:C1710[$classeName].__prototype).sort()
		
		$form:=New object:C1471
		
		$form.callbacks:=cs:C1710.sfw_documentationEntryCallback.me.callbacks.copy()
		For each ($callback; $form.callbacks)
			$selected:=($memberFunctions.indexOf($callback.title)=-1)
			$callback.selected:=False:C215
			$callback.meta:=New object:C1471
			If ($selected=False:C215)
				$callback.meta.unselectable:=True:C214
				$callback.meta.disabled:=True:C214
			End if 
		End for each 
		
		$refWindow:=Open form window:C675("sfw_selector_callback"; Modal form dialog box:K39:7)
		DIALOG:C40("sfw_selector_callback"; $form)
		CLOSE WINDOW:C154($refWindow)
		
		If (ok=1)
			$lines:=New collection:C1472()
			
			For each ($callback; $form.callbacks)
				If ($callback.selected)
					If ($callback.syntax=Null:C1517)
						$line:="local Function "+$callback.title+"()"
					Else 
						$line:=$callback.syntax
					End if 
					$lines.push($line)
					If ($callback.comment#Null:C1517)
						$lines.push("// "+$callback.comment)
					End if 
					$line:=""
					$lines.push($line)
				End if 
			End for each 
			
			$textToInsert:=$lines.join("\r")
			
			SET MACRO PARAMETER:C998(Highlighted method text:K5:18; $textToInsert)
		End if 
End case 