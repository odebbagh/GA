singleton Class constructor
	
	
Function readCssFile()->$cssRules : Collection
	// Méthode : ParseCSS_to_JSON
	
	// Déclaration des variables
	var $cssPath : Object  // Utilisation d'un objet File
	var $cssContent : Text
	var $jsonOutput : Object
	var $regex : Text
	var $found : Boolean
	var $pos_found : Integer
	var $length_found : Integer
	var $ruleText : Text
	var $matches : Collection
	var $i : Integer
	var $ruleObject : Object
	var $properties : Collection
	var $propertyPair : Collection
	var $propertyName : Text
	var $propertyValue : Text
	
	// Déterminer le chemin du fichier CSS dans le sous-dossier "sources"
	$cssPath:=Folder:C1567(fk database folder:K87:14).folder("Project/Sources").file("styleSheets.css")
	
	// Vérifier si le fichier existe
	If ($cssPath.exists=True:C214)
		// Lire le contenu du fichier en utilisant getText()
		$cssContent:=$cssPath.getText()
		
		// Initialiser une collection pour stocker les règles CSS
		$cssRules:=New collection:C1472
		
		// Expression régulière pour capturer les sélecteurs et leurs propriétés
		$regex:="(?m)^\\s*([^{}]+)\\s*\\{\\s*([^}]+)\\s*\\}"  // Regex pour extraire les blocs CSS
		
		// Initialiser la position et la longueur avant l'appel de la regex
		$pos_found:=0
		$length_found:=0
		
		Repeat 
			// Trouver toutes les correspondances dans le fichier CSS
			$found:=Match regex:C1019($regex; $cssContent; 1; $pos_found; $length_found)
			
			If ($found)
				// Extraire la règle CSS correspondante
				$ruleText:=Replace string:C233(Substring:C12($cssContent; $pos_found; $length_found); "\r"; "")
				
				
				// Créer un objet pour stocker la règle CSS
				$ruleObject:=New object:C1471
				// Extraire et nettoyer le sélecteur
				$posCurlyBracket:=Position:C15("{"; $ruleText)
				$selector:=cs:C1710.sfw_string.me.trimSpace(Substring:C12($ruleText; 1; $posCurlyBracket-1))
				
				$posEndingCurlyBracket:=Position:C15("}"; $ruleText)
				$ruleText:=Substring:C12($ruleText; $posCurlyBracket+1; $posEndingCurlyBracket-1)
				$ruleObject["selector"]:=cs:C1710.sfw_string.me.trimSpace($selector)
				
				// Extraire les propriétés et les ajouter sous forme de clé/valeur dans un objet
				$ruleObject["properties"]:=New object:C1471
				$properties:=Split string:C1554(Substring:C12($ruleText; $pos_found+1; $length_found-$pos_found-1); ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)  // Séparation des propriétés
				
				// Parcourir chaque propriété
				For ($i; 0; $properties.length-1)
					$propertyPair:=Split string:C1554($properties[$i]; ":")  // Séparation clé:valeur
					If ($propertyPair.length=2)
						// Nettoyer et ajouter la propriété à l'objet
						$propertyName:=cs:C1710.sfw_string.me.trimSpace($propertyPair[0])
						$propertyValue:=cs:C1710.sfw_string.me.trimSpace($propertyPair[1])
						$ruleObject["properties"][$propertyName]:=$propertyValue
					End if 
				End for 
				
				// Ajouter la règle à la collection
				$cssRules.push($ruleObject)
				$cssContent:=Substring:C12($cssContent; $length_found+1)
			End if 
		Until ($found=False:C215)
		
	Else 
	End if 
	