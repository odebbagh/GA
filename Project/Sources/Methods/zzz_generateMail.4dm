//%attributes = {}
#DECLARE($ePerson : cs:C1710.PersonEntity)->$mail : Text

$lastname:=Lowercase:C14($ePerson.lastName)
$firstname:=Lowercase:C14($ePerson.firstName)

$nb_operator:=(Random:C100%20)
Case of 
	: ($nb_operator<8)
		$operator:="gmail"
	: ($nb_operator<11)
		$operator:="hotmail"
	: ($nb_operator<14)
		$operator:="outlook"
	: ($nb_operator<16)
		$operator:="yahoo"
	: ($nb_operator<20)
		$operator:="iCloud"
	Else 
		$operator:="zoho"
End case 

$nb_extension:=(Random:C100%20)
Case of 
	: ($nb_extension<10)
		$extension:="com"
	: ($nb_extension<15)
		$extension:="org"
	: ($nb_extension<17)
		$extension:="net"
	: ($nb_extension=18)
		$extension:="eu"
	: ($nb_extension=19)
		$extension:="us"
	Else 
		$extension:="uk"
End case 


$nb:=(Random:C100%12)
Case of 
	: ($nb<5)
		$mail:=$firstname+"."+$lastname+"@"+$operator+"."+$extension
	: ($nb<7)
		$mail:=Substring:C12($firstname; 0; 1)+"."+$lastname+"@"+$operator+"."+$extension
	: ($nb=7)
		$mail:=$firstname+"."+Substring:C12($lastname; 0; 1)+"@"+$operator+"."+$extension
	: ($nb=8)
		$mail:=$firstname+"@"+$lastname+"."+$extension
	: ($nb=9)
		$mail:=$lastname+"@"+$firstname+"."+$extension
	: ($nb=10)
		$mail:=$lastname+String:C10(Random:C100%99)+"@"+$operator+"."+$extension
	Else 
		$mail:=$firstname+"."+$lastname+String:C10(Random:C100%99)+"@"+$operator+"."+$extension
End case 