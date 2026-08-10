#DECLARE($actionData : Object)->$result : Object

var $action; $context; $parameters : Object
$action:=MobileAppServer.Action.new($actionData)
$context:=$action.request.context
$parameters:=$action.request.parameters
$userInfo:=$action.request.userInfo
$result:=New object:C1471("success"; False:C215)

Case of 
	: ($action.name="booking")
		
		$entity:=$context.entity
		If ($entity#Null:C1517)
			$primaryKey:=$entity.primaryKey
		End if 
		
		var $choiceList : Collection  // or obj if wanted (according to some format
		$choiceList:=New collection:C1472
		$medicalHouses:=ds:C1482.MedicalCapability.query("UUID_ConsultationKind = :1"; $primaryKey).medicalHouse
		
		For each ($medicalHouse; $medicalHouses)
			$choiceList.push(New object:C1471("key"; $medicalHouse.UUID; "value"; $medicalHouse.name))
		End for each 
		
		$result.parameters:=New collection:C1472
		$result.parameters.push(New object:C1471("name"; "dateReservation"; "label"; ds:C1482.sfw_readXliff("mobile.date"; "Date"); "type"; "date"))
		$result.parameters.push(New object:C1471("name"; "centre"; "label"; ds:C1482.sfw_readXliff("mobile.centre"; "Medical house"); "type"; "text"; "choiceList"; $choiceList))
		$result.name:="ValidMH"  // name of the "dynamic" action managed by next case of
		$result.label:=ds:C1482.sfw_readXliff("mobile.title"; "New appointement")  // "Réservation"
		$result.style:=New object:C1471("dismissLabel"; ds:C1482.sfw_readXliff("mobile.cancel"; "Cancel"); "doneLabel"; ds:C1482.sfw_readXliff("mobile.next"; "Next"))
		$result.success:=True:C214
		
	: ($action.name="ValidMH")
		
		$entity:=$context.entity
		If ($entity#Null:C1517)
			$primaryKey:=$entity.primaryKey
		End if 
		
		$medicalHouse_UUID:=$parameters.centre
		$dateReservation:=$parameters.dateReservation
		$choiceList:=New collection:C1472
		$medicalStaffs:=ds:C1482.MedicalCapability.query("UUID_ConsultationKind = :1 & UUID_MedicalHouse = :2"; $primaryKey; $medicalHouse_UUID).medicalStaff
		
		For each ($medicalStaff; $medicalStaffs)
			$choiceList.push(New object:C1471("key"; $medicalStaff.UUID; "value"; $medicalStaff.firstName+" "+$medicalStaff.lastName))
		End for each 
		
		$result.parameters:=New collection:C1472
		$result.parameters.push(New object:C1471("name"; "dateReservation"; "label"; ds:C1482.sfw_readXliff("mobile.date"; "Date"); "type"; "date"; "default"; $dateReservation))
		$result.parameters.push(\
			New object:C1471("name"; "centre"; "label"; ds:C1482.sfw_readXliff("mobile.centre"; "Medical house"); "type"; "text"; "default"; $medicalHouse_UUID; "choiceList"; \
			New collection:C1472(New object:C1471("key"; $medicalHouse_UUID; "value"; ds:C1482.MedicalHouse.get($medicalHouse_UUID).name))))
		
		$result.parameters.push(New object:C1471("name"; "doctor"; "label"; ds:C1482.sfw_readXliff("mobile.doctor"; "Doctor"); "type"; "text"; "choiceList"; $choiceList))
		$result.name:="ValidDoctor"  // name of the "dynamic" action managed by next case of
		$result.label:=ds:C1482.sfw_readXliff("mobile.title"; "New appointement")
		$result.style:=New object:C1471("dismissLabel"; ds:C1482.sfw_readXliff("mobile.cancel"; "Cancel"); "doneLabel"; ds:C1482.sfw_readXliff("mobile.next"; "Next"))
		$result.success:=True:C214
		
	: ($action.name="ValidDoctor")
		
		$entity:=$context.entity
		If ($entity#Null:C1517)
			$primaryKey:=$entity.primaryKey
		End if 
		
		$dateReservation:=$parameters.dateReservation
		$medicalStaff_UUID:=$parameters.doctor
		$medicalHouse_UUID:=$parameters.centre
		
		$schedule:=ds:C1482.Appointment.availableAppointements($dateReservation; New object:C1471("uuid_staff"; $medicalStaff_UUID; "uuid_medicalHouse"; $medicalHouse_UUID; "uuid_consultation"; $primaryKey))
		$schedule:=$schedule.map("toObjectCollection")
		
		$result.parameters:=New collection:C1472
		$result.parameters.push(New object:C1471("name"; "dateReservation"; "label"; ds:C1482.sfw_readXliff("mobile.date"; "Date"); "type"; "date"; "default"; $dateReservation))
		$result.parameters.push(\
			New object:C1471("name"; "centre"; "label"; ds:C1482.sfw_readXliff("mobile.centre"; "Medical house"); "type"; "text"; "default"; $medicalHouse_UUID; "choiceList"; \
			New collection:C1472(New object:C1471("key"; $medicalHouse_UUID; "value"; ds:C1482.MedicalHouse.get($medicalHouse_UUID).name))))
		
		$medicalStaff:=ds:C1482.MedicalStaff.get($medicalStaff_UUID)
		$result.parameters.push(New object:C1471("name"; "doctor"; "label"; ds:C1482.sfw_readXliff("mobile.doctor"; "Doctor"); "type"; "text"; "default"; $medicalStaff_UUID; "choiceList"; \
			New collection:C1472(New object:C1471("key"; $medicalStaff_UUID; "value"; $medicalStaff.firstName+" "+$medicalStaff.lastName))))
		
		$result.parameters.push(New object:C1471("name"; "slot"; "label"; ds:C1482.sfw_readXliff("mobile.slot"; "Slot"); "type"; "text"; "choiceList"; $schedule))
		$result.style:=New object:C1471("dismissLabel"; ds:C1482.sfw_readXliff("mobile.cancel"; "Cancel"); "doneLabel"; ds:C1482.sfw_readXliff("mobile.next"; "Next"))
		$result.name:="ValidSlot"  // name of the "dynamic" action managed by next case of
		$result.label:=ds:C1482.sfw_readXliff("mobile.title"; "New appointement")
		$result.success:=True:C214
		
	: ($action.name="ValidSlot")
		
		$entity:=$context.entity
		If ($entity#Null:C1517)
			$primaryKey:=$entity.primaryKey
		End if 
		
		$appointment:=ds:C1482.Appointment.new()
		$appointment.UUID_MedicalStaff:=$parameters.doctor
		$appointment.UUID_MedicalHouse:=$parameters.centre
		$appointment.UUID_ConsultationKind:=$entity.primaryKey
		$appointment.UUID_Person:=$userInfo.UUID
		$appointment.startStmp:=cs:C1710.sfw_stmp.me.build\
			(Date:C102($parameters.dateReservation); \
			Time:C179($parameters.slot))
		$appointment.duration:=900
		$appointment.idStatus:=3  // mobile
		// $appointment.chronoStatus:=New object("histo"; New collection; "expiration"; sfw_stmp_build(Current date; Current time+?00:15:00?))
		$info:=$appointment.save()
		If ($info.success)
			$result.success:=True:C214
			$result.statusText:=ds:C1482.sfw_readXliff("mobile.status_1"; "Appointment taking")  //"RDV pris avec success"
			$result.dataSynchro:=True:C214
			$result.dataClass:="Appointment"
		Else 
			$result.statusText:=ds:C1482.sfw_readXliff("mobile.error_1"; "Error occurred")
			$result.success:=False:C215
		End if 
		
	Else 
		$result.statusText:=ds:C1482.sfw_readXliff("mobile.error_2"; "Unknown request send")
End case 