# sfw_countryManager

The `sfw_countryManager` class is designed to manage country-related data and provide functionalities such as loading country data into cache and generating a popup menu for country selection.

### Summary

| |
| -------- |
|[.get_pupMenu(countryCode : Text)](#-get_pupmenu-) <br> Generates a popup menu for country selection and returns the chosen country. |

<!--   get_pupMenu() *********************   -->
## .get_pupMenu()

### .get_pupMenu(countryCode : Text) -> chosenCountry : Object

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| countryCode  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The ISO code of the country to be pre-selected in the menu |
| chosenCountry  | Object  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | The chosen country object |

#### Description

The `.get_pupMenu()` function generates a popup menu for country selection. It includes both preferred countries and all other countries. The function returns the chosen country object based on the user's selection.

#### Example
```4d
$chosenCountry:=cs.sfw_countryManager.get_pupMenu("US")
```

### Usage Example

This class allows you to manage country-related data and generate a popup menu for country selection. Here is an example of how to use this class:

```4d
$countryManager:=cs.sfw_countryManager.new()
$chosenCountry:=cs.sfw_countryManager.get_pupMenu("US")
If ($chosenCountry#Null)
    ALERT("You selected: "+$chosenCountry.name)
Else 
    ALERT("No country selected")
End if
```