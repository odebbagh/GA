property ident : Text
property allowedProfiles : Collection

Class constructor($ident : Text)
	
	This:C1470.ident:=$ident
	This:C1470.allowedProfiles:=["designer"]
	
Function _insertDynamicPage($formDefinition : Object; $panelPage : Object; $offsetHorizontal : Integer; $offsetVertical : Integer)
	var $pageDefinition : Object
	$dynamicSource:=$panelPage.dynamicSource
	OBJECT GET COORDINATES:C663(*; "detail_panel"; $g; $h; $d; $b)
	$widthDetailPanel:=$d-$g
	$heightDetailPanel:=$b-$h
	$gutter:=5
	$pageDefinition:=$formDefinition.pages[$panelPage.page]
	
	$inputMoreData:=New object:C1471
	$inputMoreData.type:="input"
	$inputMoreData.dataSource:="json stringify(Form.current_item.moreData;*)"
	$inputMoreData.top:=$offsetVertical+$gutter
	$inputMoreData.left:=$offsetHorizontal+$gutter
	$inputMoreData.width:=$widthDetailPanel-(2*$gutter)-16  // scrollbar = 16
	$inputMoreData.height:=$heightDetailPanel-(2*$gutter)-$offsetVertical
	//$inputMoreData.events:=["onClick"]
	$inputMoreData.focusable:=False:C215
	$inputMoreData.enterable:=False:C215
	$inputMoreData.hideFocusRing:=True:C214
	$inputMoreData.scrollbarVertical:="visible"
	$inputMoreData.borderStyle:="none"
	$inputMoreData.showSelection:=True:C214
	$inputMoreData.placeholder:=ds:C1482.sfw_readXliff("definitionpagemoredata.placeholder")  //OKXLIFF
	$pageDefinition.objects["input_"+$dynamicSource.ident]:=$inputMoreData
	
	
	
	