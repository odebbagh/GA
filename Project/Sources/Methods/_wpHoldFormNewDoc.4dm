//%attributes = {}
// _wpHoldFormNewDoc -> an empty Write Pro document set up like the GAF paper forms: US Letter
// portrait, 1.5cm margins (18.59cm of usable width), Arial 9 black. See _ga_buildHoldFormTemplates.
#DECLARE()->$doc : Object

$doc:=WP New("")

WP SET ATTRIBUTES($doc; wk layout unit; wk unit cm)
WP SET ATTRIBUTES($doc; wk font family; "Arial")
WP SET ATTRIBUTES($doc; wk font size; 9)
WP SET ATTRIBUTES($doc; wk text color; "#000000")

WP SET ATTRIBUTES($doc; wk page width; "21.59cm")
WP SET ATTRIBUTES($doc; wk page height; "27.94cm")
WP SET ATTRIBUTES($doc; wk page orientation; wk portrait)

// wk page margin, not wk margin (the element's own margin)
WP SET ATTRIBUTES($doc; wk page margin left; "1.5cm")
WP SET ATTRIBUTES($doc; wk page margin right; "1.5cm")
WP SET ATTRIBUTES($doc; wk page margin top; "1.5cm")
WP SET ATTRIBUTES($doc; wk page margin bottom; "1.5cm")
