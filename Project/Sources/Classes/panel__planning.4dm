singleton Class constructor
	// It's a singleton class
	
Function refreshStepsTabLayout($showDetail : Boolean)
	var $widthSubform : Integer
	var $heightSubform : Integer
	var $leftSidebar : Integer
	var $topPanel : Integer
	var $rightSidebar : Integer
	var $bottomSidebar : Integer
	var $leftLb : Integer
	var $topLb : Integer
	var $rightLb : Integer
	var $bottomLb : Integer
	var $leftAction : Integer
	var $topAction : Integer
	var $rightAction : Integer
	var $bottomAction : Integer
	var $widthUpDownBtns : Integer
	var $hzDistancing : Integer
	var $detailWidth : Integer
	var $listRight : Integer
	var $detailLeft : Integer
	var $labLeft : Integer
	var $inpLeft : Integer
	var $inpRight : Integer
	var $btnRight : Integer
	var $btnTop : Integer
	var $btnBottom : Integer
	var $actionH : Integer
	//var $_formObjects : Array
	//var $_variablesArray : Array
	//var $_pagesArray : Array
	var $i : Integer
	var $obLeft : Integer
	var $obTop : Integer
	var $obRight : Integer
	var $obBottom : Integer
	var $objectName : Text
	
	If (FORM Get current page:C276(*)#2)
		return 
	End if 
	
	$widthUpDownBtns:=26
	$hzDistancing:=10
	$detailWidth:=300
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $leftSidebar; $topPanel; $rightSidebar; $bottomSidebar)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $leftSidebar; $topPanel; $rightSidebar; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_steps"; $leftLb; $topLb; $rightLb; $bottomLb)
	
	If ($showDetail)
		$listRight:=$widthSubform-$widthUpDownBtns-$detailWidth-$hzDistancing
	Else 
		$listRight:=$widthSubform-$widthUpDownBtns-$hzDistancing
	End if 
	
	OBJECT SET COORDINATES:C1248(*; "lb_steps"; $rightSidebar; $topLb; $listRight; $heightSubform)
	
	This:C1470.setStepPositionState()
	
	OBJECT GET COORDINATES:C663(*; "bActionSteps"; $leftAction; $topAction; $rightAction; $bottomAction)
	$actionH:=$bottomAction-$topAction
	OBJECT SET COORDINATES:C1248(*; "bActionSteps"; $leftAction; $heightSubform-$actionH-10; $rightAction; $heightSubform-10)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_first"; $obLeft; $btnTop; $btnRight; $btnBottom)
	$detailLeft:=$btnRight+$hzDistancing
	
	If ($showDetail)
		OBJECT SET VISIBLE:C603(*; "df@"; True:C214)
		OBJECT SET VISIBLE:C603(*; "bgkd"; True:C214)
		
		OBJECT SET COORDINATES:C1248(*; "bgkd"; $detailLeft; $topLb-1; $widthSubform-4; $heightSubform)
		
		$labLeft:=$detailLeft+10
		$inpLeft:=$labLeft+90
		$inpRight:=$widthSubform-12
		
		FORM GET OBJECTS:C898($_formObjects; $_variablesArray; $_pagesArray; Form current page:K67:6)
		
		For ($i; 1; Size of array:C274($_formObjects))
			$objectName:=$_formObjects{$i}
			Case of 
				: ($objectName="df_steps_label@")
					OBJECT GET COORDINATES:C663(*; $objectName; $obLeft; $obTop; $obRight; $obBottom)
					OBJECT SET COORDINATES:C1248(*; $objectName; $labLeft; $obTop; $labLeft+80; $obBottom)
				: ($objectName="df_steps_entry_description")
					OBJECT GET COORDINATES:C663(*; $objectName; $obLeft; $obTop; $obRight; $obBottom)
					OBJECT SET COORDINATES:C1248(*; $objectName; $inpLeft; $obTop; $inpRight; $obBottom)
				: ($objectName="df_steps_entry_control_params")
					OBJECT GET COORDINATES:C663(*; $objectName; $obLeft; $obTop; $obRight; $obBottom)
					OBJECT SET COORDINATES:C1248(*; $objectName; $inpLeft; $obTop; $inpRight; $heightSubform-8)
				: ($objectName="df_steps_entry@")
					OBJECT GET COORDINATES:C663(*; $objectName; $obLeft; $obTop; $obRight; $obBottom)
					OBJECT SET COORDINATES:C1248(*; $objectName; $inpLeft; $obTop; $inpRight; $obBottom)
			End case 
		End for 
	Else 
		OBJECT SET VISIBLE:C603(*; "df@"; False:C215)
		OBJECT SET VISIBLE:C603(*; "bgkd"; False:C215)
	End if 
	
Function displayDetailForm()
	This:C1470.refreshStepsTabLayout(True:C214)
	
Function hideDetailForm()
	This:C1470.refreshStepsTabLayout(False:C215)
	
Function setStepPositionState()
	
	$widthUpDownBtns:=26
	$hzDistancing:=10
	
	OBJECT GET COORDINATES:C663(*; "lb_steps"; $left_lb; $top_lb; $right_lb; $bottom_lb)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_first"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_move_first"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_up"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_move_up"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_down"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_move_down"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_last"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_move_last"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	OBJECT GET COORDINATES:C663(*; "btn_delete_row"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_delete_row"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	