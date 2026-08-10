//%attributes = {}
QUERY:C277([Staff:135]; [Staff:135]UUID:1=Form:C1466.current_item.UUID)

//FORM SET OUTPUT([Staff]; "cert_training")
//PRINT RECORD([Staff])

PRINT SETTINGS:C106()

OPEN PRINTING JOB:C995

$form:=New object:C1471()

$form.employee:=New object:C1471(\
"lastName"; [Staff:135]lastName:5; \
"firstName"; [Staff:135]firstName:4; \
"department"; [Staff:135]department:11; \
"division"; [Staff:135]division:14; \
"code"; [Staff:135]code:10; \
"retrainingDate"; [Staff:135]retrainDate:3\
)

Print form:C5([Staff:135]; "cert_training"; $form; Form header:K43:3)

QUERY:C277([CertificationAssignment:134]; [CertificationAssignment:134]UUID_Staff:2=Form:C1466.current_item.UUID; *)
QUERY:C277([CertificationAssignment:134];  & ; [CertificationAssignment:134]expiredIn:5>=cs:C1710.sfw_stmp.me.now())

For ($i; 1; Records in selection:C76([CertificationAssignment:134]))
	QUERY:C277([Certification:124]; [Certification:124]UUID:1=[CertificationAssignment:134]UUID_Certification:3)
	$form:=New object:C1471()
	
	$form.certification:=New object:C1471(\
		"name"; [Certification:124]name:2; \
		"date"; cs:C1710.sfw_stmp.me.getDate([CertificationAssignment:134]certificationDate:4)\
		)
	Print form:C5([Staff:135]; "cert_training"; $form; Form detail:K43:1)
	Print form:C5([Staff:135]; "cert_training"; Form break0:K43:14)
	
	NEXT RECORD:C51([CertificationAssignment:134])
End for 

QUERY:C277([CertificationAssignment:134]; [CertificationAssignment:134]UUID_Staff:2=Form:C1466.current_item.UUID; *)
QUERY:C277([CertificationAssignment:134];  & ; [CertificationAssignment:134]expiredIn:5<cs:C1710.sfw_stmp.me.now())

Print form:C5([Staff:135]; "other_traning"; Form header:K43:3)

For ($i; 1; Records in selection:C76([CertificationAssignment:134]))
	QUERY:C277([Certification:124]; [Certification:124]UUID:1=[CertificationAssignment:134]UUID_Certification:3)
	$form:=New object:C1471()
	
	$form.certification:=New object:C1471(\
		"name"; [Certification:124]name:2; \
		"date"; cs:C1710.sfw_stmp.me.getDate([CertificationAssignment:134]certificationDate:4)\
		)
	Print form:C5([Staff:135]; "cert_training"; $form; Form detail:K43:1)
	Print form:C5([Staff:135]; "cert_training"; Form break0:K43:14)
	
	NEXT RECORD:C51([CertificationAssignment:134])
End for 


Print form:C5([Staff:135]; "cert_training"; Form footer:K43:2)

CLOSE PRINTING JOB:C996
