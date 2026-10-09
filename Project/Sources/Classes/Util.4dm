singleton Class constructor
	
Function trim($text : Text; $chars : Collection)->$result : Text
	$result:=$text
	For each ($char; $chars)
		$items:=Split string:C1554($result; $char; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
		$result:=$items.join($char)
	End for each 
	
	
Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.startDate=Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.startDate:=Current date:C33()
		End use 
	End if 
	If (Storage:C1525.cache.endDate=Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.endDate:=Current date:C33()
		End use 
	End if 
	If (Undefined:C82(Storage:C1525.cache.interval))
		Use (Storage:C1525.cache)
			Storage:C1525.cache.interval:="0"
		End use 
	End if 
	If (Undefined:C82(Storage:C1525.cache.selectedYear)) | (Storage:C1525.cache.selectedYear=Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.selectedYear:=0
		End use 
	End if 
	
	
Function setDateInterval($pushUp; $title)
	This:C1470.cacheLoad()
	
	$form:=New object:C1471
	$form.startDate:=Storage:C1525.cache.startDate
	$form.endDate:=Storage:C1525.cache.endDate
	$form.interval:=Storage:C1525.cache.interval
	MOUSE POSITION:C468($mouseX; $mouseY; $mouseButtons)
	CONVERT COORDINATES:C1365($mouseX; $mouseY; XY Current form:K27:5; XY Main window:K27:8)
	If ($pushUp)
		$mouseY:=$mouseY-190
		$mouseX:=$mouseX-100
	End if 
	$form.pushUp:=$pushUp
	$windRef:=Open window:C153($mouseX; $mouseY; $mouseX+270; $mouseY+165; Movable dialog box:K34:7; "Set date interval")
	DIALOG:C40("_ga_setDateInterval"; $form)
	CLOSE WINDOW:C154($windRef)
	Use (Storage:C1525.cache)
		Storage:C1525.cache.startDate:=$form.startDate
		Storage:C1525.cache.endDate:=$form.endDate
		Storage:C1525.cache.interval:=$form.interval
	End use 
	
	
	// Purpose: Show year list picker (_ga_customFilter) at mouse position; store result in Storage.cache.selectedYear.
	// Same client-side dialog pattern as setDateInterval — safe when called from a local ORDA subset function.
	// Parameters:
	// $title : Text — dialog title
	// $years : Collection — year values extracted from date fields (duplicates removed, newest first)
	// Returns: nothing — read Storage.cache.selectedYear after call (0 if cancelled)
	// created by 4D/PS [2026-june-08]
	// modified by 4D/PS [2026-october-05]
Function setYearPicker($title : Text; $years : Collection)
	
	var $form : Object
	var $year : Variant
	var $uniqueYears : Collection
	
	This:C1470.cacheLoad()
	
	$form:=New object:C1471
	$form.lb_data:=New collection:C1472()
	If ($years=Null:C1517)
		$years:=New collection:C1472()
	End if 
	$uniqueYears:=$years.distinct().sort()
	If ($uniqueYears.length>0)
		$uniqueYears:=$uniqueYears.reverse()
	End if 
	For each ($year; $uniqueYears)
		If (Num:C11($year)>0)
			$form.lb_data.push(New object:C1471("value"; $year))
		End if 
	End for each 
	If ($form.lb_data.length=0)
		cs:C1710.sfw_dialog.me.alert("There are no years to choose from.")
		Use (Storage:C1525.cache)
			Storage:C1525.cache.selectedYear:=0
		End use 
		return 
	End if 
	$form.selectedPos:=0
	$form.selected:=New object:C1471("value"; "")
	$form.title:=$title
	MOUSE POSITION:C468($mouseX; $mouseY; $mouseButtons)
	CONVERT COORDINATES:C1365($mouseX; $mouseY; XY Current form:K27:5; XY Main window:K27:8)
	$windRef:=Open window:C153($mouseX; $mouseY; $mouseX+270; $mouseY+165; Movable dialog box:K34:7; $title)
	DIALOG:C40("_ga_customFilter"; $form)
	CLOSE WINDOW:C154($windRef)
	Use (Storage:C1525.cache)
		If ($form.selected#Null:C1517) && (String:C10($form.selected.value)#"")
			Storage:C1525.cache.selectedYear:=Num:C11($form.selected.value)
		Else 
			Storage:C1525.cache.selectedYear:=0
		End if 
	End use 
	
	
Function btnDatePicker($object; $attribut)->$applied : Boolean
	// Purpose: Apply a calendar date only when the user accepts a different day. Cancel (or the same date) must not mark the record dirty.
	// modified by 4D/PS [2026-october-05]
	$applied:=False:C215
	If ($object=Null:C1517) | ($attribut="")
		return 
	End if 
	
	$form:=New object:C1471
	$form.date:=$object[$attribut]
	
	OBJECT GET COORDINATES:C663(Self:C308->; $left; $top; $rigth; $bottom)
	CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
	Open window:C153($left; $bottom; $left+285; $bottom+210; Movable dialog box:K34:7; "calendar")
	DIALOG:C40("_ga_calendar"; $form)
	
	If (OK=1) && ($form.calendar#Null:C1517) && ($form.calendar.display#Null:C1517)
		$newDate:=$form.calendar.display.date
		$currentDate:=$object[$attribut]
		If (Value type:C1509($currentDate)#Is date:K8:7)
			$currentDate:=!00-00-00!
		End if 
		If ($currentDate#$newDate)
			$object[$attribut]:=$newDate
			$applied:=True:C214
		End if 
	End if 
	 
	
	
Function lockDateInputs()
	OBJECT SET ENTERABLE:C238(*; "entryField_@Date@"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "EntryField_@Date@"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "Field_@Date@"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_@date@"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "Field_@date@"; False:C215)
	
Function firstLetterLowerCase($inText : Text)->$outText : Text
	
	If (Length:C16($inText)>0)
		$inText[[1]]:=Lowercase:C14($inText[[1]])
	End if 
	$outText:=$inText
	
Function firstLetterUpperCase($inText : Text)->$outText : Text
	
	If (Length:C16($inText)>0)
		$inText[[1]]:=Uppercase:C13($inText[[1]])
	End if 
	$outText:=$inText
	
	
	// Purpose: Open selectNto1 only when there is data; never return a Null row from a blank click.
	// Parameters:
	// $objectName : Text — form object used to position the popup
	// $colName : Text — property displayed in the list
	// $data — Collection or entity selection (Null treated as empty)
	// $dataclass : Text — dataclass name passed to the form
	// $emptyMessage : Text — user message when there is nothing to pick
	// Returns: Object — selected item, or Null if cancelled / empty
	// created by 4D/PS [2026-october-05]
Function openSelectNto1($objectName : Text; $colName : Text; $data; $dataclass : Text; $emptyMessage : Text)->$item : Object
	
	$item:=Null:C1517
	If ($data=Null:C1517)
		$data:=New collection:C1472()
	End if 
	If ($data.length=0)
		If ($emptyMessage#"")
			cs:C1710.sfw_dialog.me.alert($emptyMessage)
		End if 
		return 
	End if 
	
	OBJECT GET COORDINATES:C663(*; $objectName; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	
	$form:=New object:C1471(\
		"colName"; $colName; \
		"lb_items"; $data; \
		"allData"; $data; \
		"dataclass"; $dataclass\
		)
	
	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If ((ok=1) & ($form.item#Null:C1517))
		$item:=$form.item
	End if 
	
	
	// Purpose: Rewrite a stamp only when the calendar day changes (form display must not dirty the record).
	// created by 4D/PS [2026-october-09]
Function stampIfDateChanged($currentStmp : Integer; $date : Date)->$stmp : Integer
	var $currentDate : Date
	
	If ($date=!00-00-00!)
		return 0
	End if 
	$currentDate:=$currentStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate($currentStmp; True:C214)
	If ($currentDate=$date)
		return $currentStmp
	End if 
	return cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
	
	
	// Purpose: Administration entry for lookup lists (Division, DocumentCategory, Units…).
	// created by 4D/PS [2026-october-09]
	// modified by 4D/PS [2026-october-09]
Function listEntry($ident : Text; $title : Text; $dataclass : Text; $displayOrder : Integer)->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new($ident; "administration"; $title)
	$entry.setDataclass($dataclass)
	$entry.setIcon("image/entry/task-list-50x50.png"; "image/entry/task-list-50x50.png")
	$entry.setDisplayOrder($displayOrder)
	$entry.setSearchboxField("levelID")
	$entry.setSearchboxField("code")
	$entry.setSearchboxField("name")
	$entry.setPanel("panel_List")
	$entry.setLBItemsColumn("colorPicto"; ""; "width:20"; "type:picture")
	$entry.setLBItemsColumn("levelID"; "ID"; "width:30")
	$entry.setLBItemsColumn("code"; "Code"; "width:80")
	$entry.setLBItemsColumn("name"; "Name"; "width:280")
	$entry.setLBItemsOrderBy("levelID")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	$entry.setToolBarGroup("listParameters"; "Lists"; "image/entry/task-list-50x50.png")
	
	
	// Purpose: Default levelID, color, and barcode on a new lookup-list row.
	// created by 4D/PS [2026-october-09]
	// modified by 4D/PS [2026-october-09]
Function initListRow($entity : 4D:C1709.Entity; $dataclassName : Text)
	var $max : Integer
	
	If ($entity=Null:C1517)
		return 
	End if 
	If ($entity.moreData=Null:C1517)
		$entity.moreData:=New object:C1471
	End if 
	If (Not:C34(OB Is defined:C1231($entity.moreData; "barcodeData"))) | (String:C10($entity.moreData.barcodeData)="")
		$entity.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData($dataclassName); "0000000000")
	End if 
	If (Num:C11($entity.levelID)=0)
		$max:=ds:C1482[$dataclassName].all().max("levelID")
		$entity.levelID:=($max>0) ? ($max+1) : 1
	End if 
	If (String:C10($entity.color)="")
		$entity.color:="#FFFFFF"
	End if 
	ds:C1482[$dataclassName].cacheLoad()
	
	
	// Purpose: Drop a lookup-list cache so dropdowns reload after Administration edits.
	// created by 4D/PS [2026-october-09]
	// modified by 4D/PS [2026-october-09]
Function listCacheClear($cacheKey : Text)
	If (Storage:C1525.cache#Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache[$cacheKey]:=Null:C1517
		End use 
	End if 
	
	
Function listTrigger($dataclassName : Text)
	If (Application type:C494=4D Local mode:K5:1)
		ds:C1482[$dataclassName].cacheClear()
	Else 
		EXECUTE ON CLIENT:C651("@"; "sfw_cacheManager"; "clear"; $dataclassName)
	End if 
	