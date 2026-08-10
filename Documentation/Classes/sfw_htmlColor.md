<!-- Type your summary here -->
## sfw_htmlColor

The ``sfw_htmlColor`` class manages a collection of colors and associated functionalities, including loading, fetching, and processing color-related data. It uses JSON data for configuration and incorporates SVG generation for missing color icons. 

This class also offers menu-building features for color selection and querying.

### Summary

| |
| -------- |
|[.buildMenu(menusToRelease : Collection)](#-buildmenu-)	<br> Builds and populates a color menu for selection, optionally categorizing colors by dominant color.|
|[.deployPup(hex : Text)](#-deploypup-)	<br> Deploys a dynamic color selection popup, allowing the user to select a color based on the provided hex value.|
|[.getColorPictureByColor(color : Text)](#-getcolorpicturebycolor-)	<br> Retrieves the picture associated with a specific color by name.|
|[.getColorPictureByName(colorName : Text)](#-getcolorpicturebyname-)	<br> Retrieves the picture associated with a color by its exact name.|
|[.getLuminence(color : Text)](#-getluminence-)	<br> Calculates the luminance of a color from its hexadecimal representation.|
|[.getName(hex : Text)](#-getname-)	<br> Returns the name associated with a specific hexadecimal color value.|
|[.load()](#-load-)	<br> Loads the color configuration from a JSON file and processes missing color images.|
|[.setOrderForItems(orderForItems : Text)](#-setorderforitems-) <br> Sets the order for items.|


.deployPup($hex : Text)
4d
Copier
Modifier
shared Function deployPup($hex : Text)->$color : Object
Parameter	Type		Description
$hex	Text	<img src="DocImages/arrowRight.png" height="25" align="center" />	The hexadecimal color value to start the selection.
Description
This function creates a dynamic pop-up menu for selecting a color based on the provided hexadecimal value. If Shift is pressed, it groups colors by their dominant color. The function provides the user with the ability to select a color from the menu, either based on its exact name or hex value.

Example
4d
Copier
Modifier
$color := sfw_colors.deployPup("#FF5733")

<!--   .deployPup(hex : Text) *********************   -->
## .deployPup()

### .deployPup(hex : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| hex  | Text | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The hexadecimal color value to start the selection |

#### Description
This function retrieves the picture associated with a color by its name. It first uses the `getName()` function to standardize the color name, then queries the This.colors collection to find the matching color object and returns its associated picture.

#### Example
```4d
$pict:=cs.sfw_htmlColor.me.getColorPictureByColor("Red")
```










<!--   .getColorPictureByColor(color : Text) *********************   -->
## .getColorPictureByColor()

### .getColorPictureByColor(color : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| color  | Text | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The name of the color |

#### Description
This function retrieves the picture associated with a color by its name. It first uses the `getName()` function to standardize the color name, then queries the This.colors collection to find the matching color object and returns its associated picture.

#### Example
```4d
$pict:=cs.sfw_htmlColor.me.getColorPictureByColor("Red")
```


<!--   .getColorPictureByName(colorName : Text) *********************   -->
## .getColorPictureByName()

### .getColorPictureByName(colorName : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| colorName  | Text | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The exact name of the color |

#### Description
This function retrieves the picture of a color based on its exact name. It directly queries the This.colors collection for the color's name and returns the associated image. 

This function is a more precise version of ``getColorPictureByColor()``, as it matches the exact name rather than performing name standardization.

#### Example
```4d
$pict:=cs.sfw_htmlColor.me.getColorPictureByName("Crimson")
```








<!--  .getName(hex : Text) *********************   -->
## .getName()

### .getName(hex : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| hex  | Text | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The hexadecimal color value |

#### Description
Thes `.getName()` function returns the name of a color from its hexadecimal representation. 
It queries the **This.colors** collection for any color that matches the provided hex value and returns the corresponding color name.
#### Example
```4d
$name := cs.sfw_htmlColor.me.getName("#FF5733")
```































<!--   .load() *********************   -->
## .load()

### .load()

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| menusToRelease  | Collection | <img src="DocImages/arrowRight.png"  height="25" align="center" /> |  |

#### Description

The ``.load()`` function loads color data from a JSON file (colors.json) located in the /RESOURCES/sfw/colors/ directory. It parses the JSON to extract color information into the This.colors collection. 

For each color, the function checks whether the corresponding image (in PNG format) exists. If not, it creates an SVG representation of the color and saves it as a PNG. 
The function then associates the image with the corresponding color object.

#### Example
```4d
cs.sfw_htmlColor.me.load()
```
