
$refMenus:=New collection:C1472
$refMenu:=Create menu:C408
$refMenus.push($refMenu)

$refMenuAddUser:=Create menu:C408
$refMenus.push($refMenuAddUser)
$letters:=Split string:C1554("abcdefghijklmnopqrstuvwxyz"; "")
For each ($letter; $letters)
	$esUsers:=ds:C1482.sfw_User.query("firstName = :1"; $letter+"@")
	If ($esUsers.length>0)
		$refMenuLetter:=Create menu:C408
		$refMenus.push($refMenuLetter)
		For each ($eUser; $esUsers)
			APPEND MENU ITEM:C411($refMenuLetter; $eUser.fullName; *)
			SET MENU ITEM PARAMETER:C1004($refMenuLetter; -1; "--user:"+$eUser.UUID)
		End for each 
		APPEND MENU ITEM:C411($refMenuAddUser; Uppercase:C13($letter); $refMenuLetter; *)
	End if 
End for each 
APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("user.users"); $refMenuAddUser; *)  //okXLIFF

$refMenuAddProfile:=Create menu:C408
$refMenus.push($refMenuAddUser)
$esProfiles:=ds:C1482.sfw_UserProfile.all().orderBy("name")
For each ($profile; $esProfiles)
	APPEND MENU ITEM:C411($refMenuAddProfile; $profile.name; *)
	SET MENU ITEM PARAMETER:C1004($refMenuAddProfile; -1; "--profile:"+$profile.UUID)
End for each 
APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("profile.profiles"); $refMenuAddProfile; *)  //okXLIFF

$choose:=Dynamic pop up menu:C1006($refMenu)
For each ($refMenu; $refMenus)
	RELEASE MENU:C978($refMenu)
End for each 

Case of 
	: ($choose="--user:@")
		Form:C1466.UUID_targetAssigned:=Split string:C1554($choose; ":").pop()
		$eUser:=ds:C1482.sfw_User.get(Form:C1466.UUID_targetAssigned)
		OBJECT SET TITLE:C194(*; FORM Event:C1606.objectName; "🙍🏻‍♂️ "+$eUser.fullName)
	: ($choose="--profile:@")
		Form:C1466.UUID_targetAssigned:=Split string:C1554($choose; ":").pop()
		$eProfile:=ds:C1482.sfw_UserProfile.get(Form:C1466.UUID_targetAssigned)
		OBJECT SET TITLE:C194(*; FORM Event:C1606.objectName; "👫 "+$eProfile.name)
End case 
