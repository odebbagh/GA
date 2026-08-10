//%attributes = {}

var $countryRaw : Text
var $iso : Text

$countryRaw:=$1
$iso:="US"

Case of 
	: (($countryRaw="UNITED STATES") | ($countryRaw="UNITED STATES OF AMERICA") | ($countryRaw="USA"))
		$iso:="US"
	: (($countryRaw="CANADA") | ($countryRaw="CA"))
		$iso:="CA"
	: (($countryRaw="MEXICO") | ($countryRaw="MX"))
		$iso:="MX"
	: (($countryRaw="UNITED KINGDOM") | ($countryRaw="UK") | ($countryRaw="GREAT BRITAIN") | ($countryRaw="ENGLAND"))
		$iso:="GB"
	: (($countryRaw="GERMANY") | ($countryRaw="DE"))
		$iso:="DE"
	: (($countryRaw="FRANCE") | ($countryRaw="FR"))
		$iso:="FR"
	: (($countryRaw="ITALY") | ($countryRaw="IT"))
		$iso:="IT"
	: (($countryRaw="SPAIN") | ($countryRaw="ES"))
		$iso:="ES"
	: (($countryRaw="NETHERLANDS") | ($countryRaw="NL"))
		$iso:="NL"
	: (($countryRaw="BELGIUM") | ($countryRaw="BE"))
		$iso:="BE"
	: (($countryRaw="SWITZERLAND") | ($countryRaw="CH"))
		$iso:="CH"
	: (($countryRaw="IRELAND") | ($countryRaw="IE"))
		$iso:="IE"
	: (($countryRaw="PORTUGAL") | ($countryRaw="PT"))
		$iso:="PT"
	: (($countryRaw="POLAND") | ($countryRaw="PL"))
		$iso:="PL"
	: (($countryRaw="CZECH REPUBLIC") | ($countryRaw="CZECHIA") | ($countryRaw="CZ"))
		$iso:="CZ"
	: (($countryRaw="SWEDEN") | ($countryRaw="SE"))
		$iso:="SE"
	: (($countryRaw="NORWAY") | ($countryRaw="NO"))
		$iso:="NO"
	: (($countryRaw="DENMARK") | ($countryRaw="DK"))
		$iso:="DK"
	: (($countryRaw="FINLAND") | ($countryRaw="FI"))
		$iso:="FI"
	: (($countryRaw="AUSTRIA") | ($countryRaw="AT"))
		$iso:="AT"
	: (($countryRaw="AUSTRALIA") | ($countryRaw="AU"))
		$iso:="AU"
	: (($countryRaw="NEW ZEALAND") | ($countryRaw="NZ"))
		$iso:="NZ"
	: (($countryRaw="JAPAN") | ($countryRaw="JP"))
		$iso:="JP"
	: (($countryRaw="CHINA") | ($countryRaw="CN"))
		$iso:="CN"
	: (($countryRaw="SOUTH KOREA") | ($countryRaw="KOREA") | ($countryRaw="KR"))
		$iso:="KR"
	: (($countryRaw="INDIA") | ($countryRaw="IN"))
		$iso:="IN"
	: (($countryRaw="SINGAPORE") | ($countryRaw="SG"))
		$iso:="SG"
	: (($countryRaw="HONG KONG") | ($countryRaw="HK"))
		$iso:="HK"
	: (($countryRaw="TAIWAN") | ($countryRaw="TW"))
		$iso:="TW"
	: (($countryRaw="BRAZIL") | ($countryRaw="BR"))
		$iso:="BR"
	: (($countryRaw="ARGENTINA") | ($countryRaw="AR"))
		$iso:="AR"
	: (($countryRaw="CHILE") | ($countryRaw="CL"))
		$iso:="CL"
End case 

$0:=$iso
