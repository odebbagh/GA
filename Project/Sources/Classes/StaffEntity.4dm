Class extends Entity

Function hasCertification($uuid_certification : Text; $duration : Integer)->$certified : Boolean
	//$certified:=(ds.CertificationAssignment.query("UUID_Staff = :1 AND UUID_Certification = :2"; This.UUID; $uuid_certification).length>0)
	$certified:=(ds:C1482.CertificationAssignment.query("UUID_Staff = :1 AND UUID_Certification = :2 AND expiredIn >= :3"; \
		This:C1470.UUID; \
		$uuid_certification; \
		cs:C1710.sfw_stmp.me.build(Current date:C33())\
		).length>0)
	
Function createCertification($uuid_certification : Text; $duration : Integer)->$certified : Boolean
	$certificationAssignment:=ds:C1482.CertificationAssignment.new()
	
	$certificationAssignment.UUID_Staff:=This:C1470.UUID
	$certificationAssignment.UUID_Certification:=$uuid_certification
	
	$certificationAssignment.certificationDate:=cs:C1710.sfw_stmp.me.now()
	//$certificationAssignment.certificationDate:=cs.sfw_stmp.me.build(!2024-06-01!)  // Test Only
	
	If ($duration>0)
		$certificationAssignment.expiredIn:=cs:C1710.sfw_stmp.me.build(Add to date:C393(Current date:C33(); 0; 0; $duration))
		//$certificationAssignment.expiredIn:=cs.sfw_stmp.me.build(Add to date(!2024-06-01!; 0; 0; $duration))  // Test Only
	End if 
	
	$res:=$certificationAssignment.save()
	
	$certified:=$res.success
	
Function deleteCertification($uuid_certification : Text)->$certified : Boolean
	$certificationAssignment_es:=ds:C1482.CertificationAssignment.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification)
	
	If ($certificationAssignment_es.length>0)
		$res:=$certificationAssignment_es[0].drop()
		
		$certified:=Not:C34($res.success)
	End if 
	
Function getCertificationDate($uuid_certification : Text)->$certifiedAt : Date
	$assignment_es:=ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification)\
		.orderBy("certificationDate desc")
	
	If ($assignment_es.length>0)
		$certifiedAt:=cs:C1710.sfw_stmp.me.getDate($assignment_es[0].certificationDate)
	End if 
	
Function getExpiredDate($uuid_certification : Text)->$expiredIn : Date
	$assignment_es:=ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification)\
		.orderBy("certificationDate desc")
	
	If ($assignment_es.length>0)
		$expiredIn:=($assignment_es[0].expiredIn>0) ? cs:C1710.sfw_stmp.me.getDate($assignment_es[0].expiredIn) : !00-00-00!
	End if 
	
Function getCertiExpiredIn($days : Integer)->$assignment_es : cs:C1710.CertificationAssignmentSelection
	var $start; $end : Integer
	
	$start:=cs:C1710.sfw_stmp.me.now()
	$end:=cs:C1710.sfw_stmp.me.build(Add to date:C393(Current date:C33(); 0; 0; $days))
	
	$assignment_es:=This:C1470.assignments.query("expiredIn >= :1 AND expiredIn <= :2"; $start; $end)
	
local Function get email()->$email : Text
	If (This:C1470.contactDetails#Null:C1517) && (This:C1470.contactDetails.communications#Null:C1517)
		$communication:=This:C1470.contactDetails.communications.query("type = :1"; "mail").first()
		If ($communication#Null:C1517)
			$email:=$communication.contact
		End if 
	End if 
	
	
local Function _initCommunication()
	If (This:C1470.contactDetails.communications=Null:C1517)
		This:C1470.contactDetails.communications:=New collection:C1472
	End if 
	
Function get fullName()->$fullName : Text
	$fullName:=[This:C1470.firstName; This:C1470.lastName].join(" ")

	// Makes fullName usable in a query (e.g. the selectNto1 picker search box):
	// the typed value (:1) is matched against the real firstName / lastName fields.
Function query fullName($event : Object)->$result : Text
	$result:="firstName = :1 OR lastName = :1"

local Function get retrainDate()->$date : Date
	$date:=This:C1470.stmpRetrain=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpRetrain; True:C214)
	
local Function set retrainDate($date : Date)
	This:C1470.stmpRetrain:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get hireDate()->$date : Date
	$date:=This:C1470.stmpHire=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpHire; True:C214)
	
local Function set hireDate($date : Date)
	This:C1470.stmpHire:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get terminationDate()->$date : Date
	$date:=This:C1470.stmpTermination=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpTermination; True:C214)
	
local Function set terminationDate($date : Date)
	This:C1470.stmpTermination:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get creationDate()->$date : Date
	$date:=This:C1470.stmpCreation=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation; True:C214)
	
local Function set creationDate($date : Date)
	This:C1470.stmpCreation:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	This:C1470._initCommunication()
	
local Function afterCreation()
	// This callback is called after saving the new item
	//This.code:=String(This.codeID; "00000#")
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470.codeID:=ds:C1482.Staff.all().max("codeID")+1
	This:C1470.code:=String:C10(This:C1470.codeID; "00000#")
	
	