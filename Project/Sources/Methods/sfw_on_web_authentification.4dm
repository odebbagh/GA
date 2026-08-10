//%attributes = {}
#DECLARE($url : Text; $header : Text; \
$BrowserIP : Text; $ServerIP : Text; \
$user : Text; $password : Text)\
->$RequestAccepted : Boolean

$requestHandler:=cs:C1710.sfw_requestHandler.new($url)
$result:=$requestHandler.dispatch()
$requestHandler.render($result)

$RequestAccepted:=True:C214
