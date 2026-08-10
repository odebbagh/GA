$activate:=(Form:C1466.validationRulesPassedWithSuccess=Null:C1517) || (Form:C1466.validationRulesPassedWithSuccess=True:C214)
$iconPathForbItemSave:=$activate ? "#sfw/image/skin/rainbow/btn4states/save-32x32.png" : "#sfw/image/skin/rainbow/btn4states/saveError-32x32.png"
OBJECT SET FORMAT:C236(*; "bItemCreate"; ";"+$iconPathForbItemSave+";")
OBJECT SET ENABLED:C1123(*; "bItemCreate"; $activate)
