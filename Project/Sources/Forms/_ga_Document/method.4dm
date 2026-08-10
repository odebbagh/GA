
Case of 
		
	: (Form event code:C388=On Load:K2:1)
		
		Form:C1466.hasAuthorizationToApprove:=False:C215
		$hasAuthorizedProfile:=False:C215
		$isFromAuthorizedTeam:=False:C215
		
		If (Form:C1466.approverProfile#Null:C1517)
			$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && (Form:C1466.approverProfile.indexOf($1.value)#-1)))#Null:C1517
			
		End if 
		
		If (Form:C1466.approverTeam#Null:C1517)
			$isFromAuthorizedTeam:=ds:C1482.Staff.query("UUID_User = :1 & memberships.team.name in :2"; cs:C1710.sfw_userManager.me.info.UUID; Form:C1466.approverTeam)#Null:C1517
			
		End if 
		Form:C1466.hasAuthorizationToApprove:=($hasAuthorizedProfile | $isFromAuthorizedTeam)
		
		OBJECT SET ENABLED:C1123(*; "isApproved"; Form:C1466.hasAuthorizationToApprove)
		OBJECT SET ENABLED:C1123(*; "approvedBy"; False:C215)
		OBJECT SET ENABLED:C1123(*; "approvalDate"; False:C215)
		
		//OBJECT SET VISIBLE(*; "PopupDate"; False)  //Form.hasAuthorizationToApprove)
		
		Form:C1466.details.clone:=OB Copy:C1225(Form:C1466.details)
		
		Form:C1466.modified:=False:C215
		
		Form:C1466.documentHasChanged:=False:C215
		
		//OBJECT SET VISIBLE(*; "isApproved"; Form.displayApprovalFields)
		//OBJECT SET VISIBLE(*; "approvedBy"; Form.displayApprovalFields)
		//OBJECT SET VISIBLE(*; "approvalDate"; Form.displayApprovalFields)
		//OBJECT SET VISIBLE(*; "PopupDate"; (Form.displayApprovalFields & Form.hasAuthorizationToApprove))
		//OBJECT SET VISIBLE(*; "approval_@"; Form.displayApprovalFields)
		
		//OBJECT GET COORDINATES(*; "Rectangle"; $left_lb; $top_lb; $right_lb; $bottom_lb)
		
		//OBJECT SET COORDINATES(*; "Rectangle"; $left_lb; $top_lb; $right_lb; $bottom_lb-120)
		
		//OBJECT GET COORDINATES(*; "bUploadDocument"; $left_lb; $top_lb; $right_lb; $bottom_lb)
		
		//OBJECT SET COORDINATES(*; "bUploadDocument"; $left_lb; $top_lb-110; $right_lb; $bottom_lb-100)
		
		//OBJECT GET COORDINATES(*; "fileName"; $left_lb; $top_lb; $right_lb; $bottom_lb)
		
		//OBJECT SET COORDINATES(*; "fileName"; $left_lb; $top_lb-100; $right_lb; $bottom_lb-100)
		
		//OBJECT GET COORDINATES(*; "bCancel"; $left_lb; $top_lb; $right_lb; $bottom_lb)
		
		//OBJECT SET COORDINATES(*; "bCancel"; $left_lb; $top_lb-100; $right_lb; $bottom_lb-100)
		
		//OBJECT GET COORDINATES(*; "bOk"; $left_lb; $top_lb; $right_lb; $bottom_lb)
		
		//OBJECT SET COORDINATES(*; "bOk"; $left_lb; $top_lb-100; $right_lb; $bottom_lb-100)
		
		//GET WINDOW RECT($left_lb; $top_lb; $right_lb; $bottom_lb; *)
		
		//SET WINDOW RECT($left_lb; $top_lb-100; $right_lb; $bottom_lb-100; *)
		
	Else 
		
		
End case 