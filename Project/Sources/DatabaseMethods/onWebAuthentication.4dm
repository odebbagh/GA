#DECLARE($url : Text; $header : Text; \
$BrowserIP : Text; $ServerIP : Text; \
$user : Text; $password : Text)\
->$RequestAccepted : Boolean

$RequestAccepted:=sfw_on_web_authentification($url; $header; $BrowserIP; $ServerIP; $user; $password)



