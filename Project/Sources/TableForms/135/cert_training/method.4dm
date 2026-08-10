Case of 
	: (FORM Event:C1606.code=On Header:K2:17)
		Form:C1466.employee:=New object:C1471(\
			"lastName"; [Staff:135]lastName:5; \
			"firstName"; [Staff:135]firstName:4; \
			"department"; [Staff:135]department:11; \
			"division"; [Staff:135]division:14; \
			"code"; [Staff:135]code:10; \
			"retrainingDate"; [Staff:135]retrainDate:3\
			)
		
	: (FORM Event:C1606.code=On Printing Detail:K2:18)
		Form:C1466.certificationName:=[Certification:124]name:2
		Form:C1466.certificationDate:=[CertificationAssignment:134]certificationDate:4
End case 