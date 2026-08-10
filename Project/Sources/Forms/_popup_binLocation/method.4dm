//var $rowHeight; $buttonBarHeight; $wantedWidth; $wantedHeight : Integer
//var $maxLabelLen; $minWidth; $maxWidth; $maxHeight : Integer
//var $item : Object

Case of 
	: (Form event code:C388=On Load:K2:1)
		
		
		If (Form:C1466.options=Null:C1517)
			Form:C1466.options:=New collection:C1472
		End if 
		If (Form:C1466.choice=Null:C1517)
			Form:C1466.choice:=""
		End if 
		
		If (Form:C1466.allowCreate=True:C214)
			OBJECT SET VISIBLE:C603(*; "btn_createSublevel"; True:C214)
		End if 
		
		
		// 1. Calcul de la hauteur nécessaire pour la Listbox
		var $rowCount; $rowHeight; $headerHeight; $totalLbHeight : Integer
		
		$rowCount:=LISTBOX Get number of rows:C915(*; "lb_options")
		$rowHeight:=LISTBOX Get rows height:C836(*; "lb_options")  // Par défaut en pixels
		OBJECT GET BEST SIZE:C717(*; "lb_options"; $listBoxWidth; $listBoxHeight)
		//$headerHeight:=LISTBOX Get headers height(*; "lb_options")
		
		// Hauteur totale = (lignes * hauteur) + entête + petite marge de sécurité (2px)
		$totalLbHeight:=($rowCount*$rowHeight)  //+$headerHeight+2
		
		// 2. Redimensionner la Listbox (OBJECT MOVE)
		// Syntaxe : OBJECT MOVE(*; "nom"; gauche; haut; largeur; hauteur)
		// On passe -1 pour les coordonnées que l'on ne veut pas changer
		//OBJECT MOVE(*; "lb_options"; -1; -1; -1; $totalLbHeight)
		
		// 3. Ajuster la fenêtre pour accompagner le changement
		var $w; $h; $left; $top : Integer
		GET WINDOW RECT:C443($left; $top; $w; $h; Current form window:C827)
		
		var $currentWinHeight : Integer
		$currentWinHeight:=$h-$top
		
		// On calcule la différence nécessaire pour la fenêtre
		// (Ajustez de '110' selon la place de vos boutons/marges en bas de formulaire)
		var $newWinHeight : Integer
		$newWinHeight:=$totalLbHeight+110
		
		RESIZE FORM WINDOW:C890(0; $newWinHeight-$currentWinHeight)
		
		
	: (Form event code:C388=On Outside Call:K2:11) | (Form event code:C388=On Close Box:K2:21)
		CANCEL:C270
End case 
