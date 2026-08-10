

Case of 
	: (FORM Event:C1606.code=-2000)
		
		cs:C1710.sfw_commentManager.me._drawCommentContainer()
		
	: (FORM Event:C1606.code=-2001)
		GOTO OBJECT:C206(*; "message_0")
		POST CLICK:C466(90; 90)  //no other choice at this moment :-(
		BRING TO FRONT:C326(Current process:C322)
		
End case 